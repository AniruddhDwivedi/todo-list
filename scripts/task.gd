extends VBoxContainer
class_name Task

signal EditRequested(task: Task)
signal DeleteRequested(task: Task)

@export var sub_box_scene: PackedScene

@onready var top_box: CheckBox = \
	$Layout/HBoxContainer/Task/HeadTask/TopBox
@onready var sub_tasks: VBoxContainer = \
	$Layout/HBoxContainer/Task/SubTasks

var task_id: String = "" 
var task_data: TaskData

var top_checked := false
var top_just_checked := false

# -------------------------
# APPLY DATA
# -------------------------
func apply_task_data(data: TaskData) -> void:
	task_data = data

	# Set title
	top_box.text = task_data.name

	# Clear old subtasks
	for child in sub_tasks.get_children():
		child.queue_free()

	# Add new subtasks
	for subtask_text in task_data.subtask_list:
		_add_subtask(subtask_text)

	# Reset checkbox state
	top_checked = false
	top_just_checked = false
	top_box.button_pressed = false


# -------------------------
# SUBTASK HANDLING
# -------------------------
func _add_subtask(text: String) -> void:
	var subtask = sub_box_scene.instantiate()
	sub_tasks.add_child(subtask)

	subtask.text = text
	subtask.top_box = top_box
	subtask.SubBoxPressed.connect(_update_checkboxes)


# -------------------------
# UI EVENTS
# -------------------------
func _on_edit_button_pressed() -> void:
	EditRequested.emit(self)


func _on_delete_button_pressed() -> void:
	DeleteRequested.emit(self)


func _on_top_box_pressed() -> void:
	top_checked = !top_checked
	top_just_checked = true
	_update_checkboxes()


# -------------------------
# CHECKBOX LOGIC
# -------------------------
func _update_checkboxes() -> void:
	var all_checked := true

	for box in sub_tasks.get_children():
		if not box.button_pressed:
			all_checked = false
			break

	if top_just_checked:
		for box in sub_tasks.get_children():
			box.button_pressed = top_checked
		top_just_checked = false
	else:
		top_checked = all_checked

	top_box.button_pressed = top_checked
