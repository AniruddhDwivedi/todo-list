extends AcceptDialog

@onready var name_label = $Layout/NameLabel

func _on_confirmed() -> void:
	SceneSwitcher.change_scene("res://scenes/main.tscn")

func _on_canceled() -> void:
	self.queue_free()
