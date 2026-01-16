extends Window

signal UpdateComplete(task_data: TaskData, task: Task)

@export var subtask_entry: PackedScene

@onready var name_entry: LineEdit = \
	$Layout/Entries/NameEntryContainer/NameLineEdit
@onready var subtask_count_entry: SpinBox = \
	$Layout/Entries/SubtaskCount/CountLineEdit
@onready var subtasks: VBoxContainer = \
	$Layout/Entries/SubtaskList/SubtasksScroll/SubLayout

var task: Task
var task_data: TaskData
var subtask_count := 0


# -------------------------
# OPEN / INITIALIZE
# -------------------------
func open_for_task(p_task: Task) -> void:
	task = p_task

	# Deep-copy data so edits are isolated
	task_data = task.task_data.duplicate(true)
	task_data.subtask_list = task_data.subtask_list.duplicate()

	# Populate UI
	name_entry.text = task_data.name
	subtask_count = task_data.subtask_list.size()
	subtask_count_entry.value = subtask_count

	_rebuild_subtask_entries()
	_fill_subtask_entries()


# -------------------------
# UI → DATA
# -------------------------
func _on_name_line_edit_text_changed(new_text: String) -> void:
	task_data.name = new_text

func _on_count_line_edit_value_changed(value: float) -> void:
	subtask_count = int(value)
	_rebuild_subtask_entries()


# -------------------------
# SUBTASK MANAGEMENT
# -------------------------
func _rebuild_subtask_entries() -> void:
	# Remove excess
	while subtasks.get_child_count() > subtask_count:
		subtasks.get_child(-1).queue_free()

	# Add missing
	while subtasks.get_child_count() < subtask_count:
		subtasks.add_child(subtask_entry.instantiate())


func _fill_subtask_entries() -> void:
	for i in range(subtasks.get_child_count()):
		if i < task_data.subtask_list.size():
			subtasks.get_child(i).subtask_value.text = \
				task_data.subtask_list[i]


# -------------------------
# SAVE / CANCEL
# -------------------------
func _on_set_button_pressed() -> void:
	task_data.subtask_list.clear()

	for entry in subtasks.get_children():
		task_data.subtask_list.append(entry.subtask_value.text)

	UpdateComplete.emit(task_data, task)
	queue_free()


func _on_cancel_button_pressed() -> void:
	queue_free()


func _on_close_requested() -> void:
	queue_free()
