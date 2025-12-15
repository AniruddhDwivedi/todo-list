extends CheckBox

signal SubBoxPressed()

@onready var top_box = null

func _on_pressed() -> void:
	emit_signal("SubBoxPressed")
