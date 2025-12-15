extends Window

signal EntryComplete(task_data: TaskData)

@export var subtask_entry : PackedScene
@export var task_data_resource : TaskData

@onready var name_entry = $Layout/Entries/NameEntryContainer/NameLineEdit
@onready var subtask_count_entry = $Layout/Entries/SubtaskCount/CountLineEdit
@onready var subtasks = $Layout/Entries/SubtaskList/SubtasksScroll/SubLayout

var subtask_count = 0
func _on_count_line_edit_value_changed(value: float) -> void:
	update_subtask_entries(value)
	subtask_count = value

func update_subtask_entries(new_subtask_count: int):
	if new_subtask_count < subtask_count:
		for i in range(new_subtask_count, subtask_count):
			print(i)
			if subtasks.get_child_count() > 0:
				var current_child = subtasks.get_child(i)
				subtasks.remove_child(current_child)

	for i in range(new_subtask_count - subtask_count):
		var new_subtask_entry = subtask_entry.instantiate()
		subtasks.add_child(new_subtask_entry)

func _on_close_requested() -> void:
	self.hide()
	self.queue_free()

func _on_set_button_pressed() -> void:
	if subtasks.get_child_count() > 0:
		for i in subtasks.get_children():
			task_data_resource.subtask_list.append(i.subtask_value.text)
		
	emit_signal("EntryComplete", task_data_resource)
	_on_close_requested()

func _on_name_line_edit_text_changed(new_text: String) -> void:
	task_data_resource.name = new_text

func _on_cancel_button_pressed() -> void:
	_on_close_requested()
