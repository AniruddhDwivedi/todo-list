extends Control

@export var task_scene: PackedScene
@export var task_entry_window: PackedScene
@export var edit_window_scene: PackedScene

@onready var task_scroll = $AppContainer/Layout/TaskScroll/TaskContainer
@onready var greeting_label = $AppContainer/Layout/TopGreetingUI/GreetingPanel/Greeting

func _ready():
	supabase.tasks_loaded.connect(_on_tasks_loaded)

	_set_greeting()

# ========================
# GREETING
# ========================
func _set_greeting():
	var hour = Time.get_datetime_dict_from_system().hour
	var greeting := "Hello"

	if hour >= 6 and hour < 12:
		greeting = "Good Morning"
	elif hour < 18:
		greeting = "Good Afternoon"
	elif hour < 22:
		greeting = "Good Evening"
	else:
		greeting = "Good Night"

	if supabase.current_username != "":
		greeting += " %s" % supabase.current_username.capitalize()

	greeting_label.text = greeting

# ========================
# TASK LOADING
# ========================
func _on_tasks_loaded(tasks: Dictionary) -> void:
	for task_id in tasks.keys():
		var task_data: TaskData = tasks[task_id]
		add_task(task_data, task_id)

# ========================
# TASK CREATION
# ========================
func _on_add_item_button_pressed() -> void:
	var entry_window = task_entry_window.instantiate()
	add_child(entry_window)

	entry_window.EntryComplete.connect(_on_task_created)
	entry_window.show()

func _on_task_created(task_data: TaskData) -> void:
	add_task(task_data)

func add_task(task_data: TaskData, task_id := "") -> void:
	var task: Task = task_scene.instantiate()
	task_scroll.add_child(task)

	task.apply_task_data(task_data)
	task.EditRequested.connect(_on_edit_task_requested)
	task.DeleteRequested.connect(_on_task_deleted)

	if task_id == "":
		supabase.save_task(task_data)
	else:
		task.task_id = task_id 

# ========================
# TASK EDITING
# ========================
func _on_edit_task_requested(task: Task) -> void:
	var edit_window = edit_window_scene.instantiate()
	add_child(edit_window)

	edit_window.open_for_task(task)
	edit_window.UpdateComplete.connect(_on_task_updated)

	edit_window.show()

func _on_task_updated(new_data: TaskData, task: Task) -> void:
	task.apply_task_data(new_data)
	supabase.update_task(task.task_id, new_data)

func _on_task_deleted(task: Task) -> void:
	if task.task_id != "":
		supabase.delete_task(task.task_id)

	task.queue_free()
# ========================
# QUIT / LOGOUT
# ========================
func _on_quit_button_pressed() -> void:
	supabase.logout()
	SceneSwitcher.change_scene("res://scenes/main.tscn")
