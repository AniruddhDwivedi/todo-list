extends Control

@export var task_scene: PackedScene
@export var task_entry_window: PackedScene
@export var edit_window_scene : PackedScene

@onready var task_scroll = $AppContainer/Layout/TaskScroll/TaskContainer
@onready var task_entry : Window = task_entry_window.instantiate()
@onready var greeting_label = $AppContainer/Layout/TopGreetingUI/GreetingPanel/Greeting
@onready var edit_window = edit_window_scene.instantiate()

func _ready():
	var current_time = Time.get_datetime_dict_from_system()
	var hour = current_time.hour
	
	var greeting = ""
	if hour >= 6 and hour < 12:
		greeting = "Good Morning!"
	elif hour >= 12 and hour < 18:
		greeting = "Good Afternoon!"
	elif hour >= 18 and hour < 22:
		greeting = "Good Evening!"
	else:
		greeting = "Good Night!"
	
	greeting_label.text = greeting
	
func _on_add_item_button_pressed() -> void:
	self.add_child(task_entry)
	task_entry.show()
	task_entry.EntryComplete.connect(add_task)
	task_entry = task_entry_window.instantiate()

func add_task(task_data: TaskData):
	var new_task = task_scene.instantiate()
	
	task_scroll.add_child(new_task)
	new_task.top_box.text = task_data.name
	
	for i in task_data.subtask_list:
		new_task.add_subtask(i)
	new_task.task_data = task_data
	new_task.EditRequested.connect(edit_task)

func edit_task(task_data: TaskData, task: Task):
	self.add_child(edit_window)
	edit_window.show()
	edit_window.name_entry.text = task_data.name
	edit_window.subtask_count_entry.value = len(task_data.subtask_list)
	print(edit_window.subtask_count_entry)
	edit_window.task = task
	edit_window.update_subtask_entries(len(task_data.subtask_list))
	
	for i in edit_window.subtasks.get_children():
		i.subtask_value.text = task_data.subtask_list.pop_front()
	
	edit_window.UpdateComplete.connect(update_task)

func update_task(task_data: TaskData, task: Task):
	task.queue_free()
	add_task(task_data)
	edit_window = edit_window_scene.instantiate()
	


func _on_quit_button_pressed() -> void:
	get_tree().quit()
