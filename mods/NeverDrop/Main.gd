extends Node

# Replace-hook Placer.Collided so a carried item is not dropped on collision.
# Place (G) is still the world put-down. Inventory drop is vanilla.

var _lib


func _ready() -> void:
	name = "NeverDrop"
	if not Engine.has_meta("RTVModLib"):
		push_error("NeverDrop: RTVModLib missing; Metro is required")
		return
	_lib = Engine.get_meta("RTVModLib")
	if _lib.hook("placer-collided", _on_collided) == -1:
		push_warning("NeverDrop: placer-collided replace already owned")


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
