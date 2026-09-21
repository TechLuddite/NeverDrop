extends Node

# Replace-hook Interface.Drop so items go back to a grid or slot instead of
# spawning as world pickups. With no room anywhere, vanilla Drop runs.
# FastDrop / ContextDrop / drag-off-UI / Close-while-dragging all call Drop().
# Death does not drop in vanilla 0.1.1.3.
# Place (G) is the world put-down. Collided is the collision drop we replace.

var _lib


func _ready() -> void:
	name = "NeverDrop"
	if not Engine.has_meta("RTVModLib"):
		push_error("NeverDrop: RTVModLib missing; Metro is required")
		return
	_lib = Engine.get_meta("RTVModLib")
	if _lib.hook("interface-drop", _on_drop) == -1:
		push_warning("NeverDrop: interface-drop replace already owned")
	if _lib.hook("placer-collided", _on_collided) == -1:
		push_warning("NeverDrop: placer-collided replace already owned")


func _on_drop(target) -> void:
	var iface = _lib._caller
	if target == null or not is_instance_valid(target) or iface == null:
		_lib.skip_super()
		return
	if _rehome(iface, target):
		_lib.skip_super()
		return
	# No grid or slot has room. Let vanilla Drop spawn the pickup: an item left
	# parented to nothing is not saved and is lost on the next scene change.
	print("NeverDrop: no room for %s, dropping to world" % str(target.slotData.itemData.name))


# Puts the item back into a grid or slot. True only if it verifiably landed.
# Return() and Place() can fail silently, e.g. SlotSwap -> AutoPlace overflow.
func _rehome(iface, target) -> bool:
	if iface.returnGrid or iface.returnSlot:
		iface.Return(target)
		if _landed(target):
			return true

	if iface.hoverGrid and iface.hoverGrid.Place(target):
		return true

	if iface.hoverSlot and target.get_parent() == iface.hoverSlot and _landed(target):
		return true

	var grid = iface.inventoryGrid
	if grid == null:
		return false
	if grid.Spawn(target):
		return true
	iface.Rotate(target)
	if grid.Spawn(target):
		return true
	iface.Rotate(target)
	return false


func _landed(target) -> bool:
	var parent = target.get_parent()
	if parent == null:
		return false
	if target.equipped and target.equipSlot == parent:
		return true
	var items = parent.get("items")
	return items is Array and items.has(target)


func _on_collided(body) -> void:
	var placer = _lib._caller
	if placer == null or not is_instance_valid(placer) or placer.placable == null or not is_instance_valid(placer.placable):
		_lib.skip_super()
		return
	# Display wall-mount: let vanilla Collided run.
	if body.is_in_group("Display") and placer.placable.slotData.itemData.type in ["Weapon", "Attachment", "Knife", "Grenade"]:
		return
	# Keep held. Do not Unfreeze, disconnect body_entered, or clear placable/isPlacing.
	_lib.skip_super()
