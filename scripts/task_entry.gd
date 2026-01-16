extends Window

signal EntryComplete(task_data: TaskData)

@export var subtask_entry: PackedScene

@onready var name_entry = $Layout/Entries/NameEntryContainer/NameLineEdit
@onready var subtask_count_entry = $Layout/Entries/SubtaskCount/CountLineEdit
@onready var subtasks = $Layout/Entries/SubtaskList/SubtasksScroll/SubLayout

var task_data: TaskData
var subtask_count := 0

func _ready() -> void:
	task_data = TaskData.new()
	task_data.subtask_list = []

func _on_name_line_edit_text_changed(new_text: String) -> void:
	task_data.name = new_text

func _on_count_line_edit_value_changed(value: float) -> void:
	update_subtask_entries(int(value))
	subtask_count = int(value)

func update_subtask_entries(new_count: int) -> void:
	while subtasks.get_child_count() > new_count:
		subtasks.get_child(-1).queue_free()

	while subtasks.get_child_count() < new_count:
		subtasks.add_child(subtask_entry.instantiate())

func _on_set_button_pressed() -> void:
	task_data.subtask_list.clear()

	for entry in subtasks.get_children():
		task_data.subtask_list.append(entry.subtask_value.text)

	EntryComplete.emit(task_data)
	queue_free()

func _on_cancel_button_pressed() -> void:
	queue_free()
