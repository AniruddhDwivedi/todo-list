extends AcceptDialog

@onready var name_label = $Layout/NameLabel

func _on_confirmed() -> void:
	self.visible = false

func _on_canceled() -> void:
	self.visible = false
