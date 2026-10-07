extends Node

# Replace-hook Placer.Collided so a carried item is not dropped on collision.
# Place (G) is still the world put-down. Inventory drop is vanilla.

var _lib
var _hooks: Array[int] = []
var _shelter_return: Node


func _ready() -> void:
	name = "NeverDrop"
	if not Engine.has_meta("RTVModLib"):
		push_error("NeverDrop: RTVModLib missing; Metro is required")
		return
	_lib = Engine.get_meta("RTVModLib")
	var collision_hook: int = _lib.hook("placer-collided", _on_collided)
	if collision_hook == -1:
		push_warning("NeverDrop: placer-collided replace already owned")
	else:
		_hooks.append(collision_hook)
	_shelter_return = preload("res://mods/NeverDrop/ShelterReturn.gd").new()
	_shelter_return.game_data = load("res://Resources/GameData.tres")
	add_child(_shelter_return)
	_hooks.append(_lib.hook("loader-saveshelter-pre", _before_save_shelter))


func _exit_tree() -> void:
	if is_instance_valid(_lib):
		for hook_id in _hooks:
			_lib.unhook(hook_id)
	_hooks.clear()


func _before_save_shelter(target_shelter) -> void:
	if is_instance_valid(_shelter_return):
		_shelter_return.before_save(target_shelter)


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
