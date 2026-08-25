extends Node

# Replace-hook Interface.Drop so items never spawn as world pickups.
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
	_lib.skip_super()
	var iface = _lib._caller
	if target == null or not is_instance_valid(target) or iface == null:
		return

	if iface.returnGrid or iface.returnSlot:
		iface.Return(target)
		return

	if iface.hoverGrid and iface.hoverGrid.Place(target):
		return

	if iface.hoverSlot and target.get_parent() == iface.hoverSlot:
		return

	var grid = iface.inventoryGrid
	if grid == null:
		return
	if target.get_parent() != grid:
		target.reparent(grid)
	if grid.Spawn(target):
		return
	iface.Rotate(target)
	if grid.Spawn(target):
		return
	iface.Rotate(target)


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
