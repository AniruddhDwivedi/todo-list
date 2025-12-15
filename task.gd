extends VBoxContainer
class_name Task

signal EditRequested(task_data: Resource)

@export var sub_box_scene : PackedScene

@onready var top_box : CheckBox = $Layout/HBoxContainer/Task/HeadTask/TopBox
@onready var sub_tasks := $Layout/HBoxContainer/Task/SubTasks
var task_data : TaskData = null
var top_checked = false
var top_just_checked = false

func _ready() -> void:
	pass

func add_subtask(child_text: String):
	var new_subtask = sub_box_scene.instantiate()
	sub_tasks.add_child(new_subtask)
	new_subtask.text = child_text
	new_subtask.top_box = top_box
	new_subtask.SubBoxPressed.connect(update_checkboxes)

func _on_delete_button_pressed() -> void:
	queue_free()

func _on_edit_button_pressed() -> void:
	emit_signal("EditRequested", task_data, self)

func update_checkboxes():
	var all_pressed = true
	for i in sub_tasks.get_children():
		if i.button_pressed:
			continue
		else:
			all_pressed = false
	
	if all_pressed and top_just_checked:
		top_checked = false
		top_box.button_pressed = false
	elif all_pressed or top_just_checked:
		top_checked = true
		top_box.button_pressed = true
	else:
		top_checked = false
		top_box.button_pressed = false
	
	if top_just_checked:
		for i in sub_tasks.get_children():
			i.button_pressed = true
		top_just_checked = false

func _on_top_box_pressed() -> void:
	top_checked = !top_checked
	top_just_checked = !top_just_checked
	update_checkboxes()
