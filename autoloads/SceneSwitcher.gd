extends Node

signal scene_changed(path: String)

func change_scene(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_error("Scene not found: " + path)
		return

	get_tree().change_scene_to_file(path)
	scene_changed.emit(path)
