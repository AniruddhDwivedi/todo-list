extends Node

# ========================
# CONFIG
# ========================
const SUPABASE_URL := "INSERT_PROJECT_URL_HERE"
const SUPABASE_ANON_KEY := "INSERT_API_KEY_HERE"
var _request_in_flight := false
var session_tasks: Dictionary = {}

# ========================
# STATE
# ========================
var current_user_id: String = ""
var current_username: String = ""

var _http: HTTPRequest
var _pending_request := ""

# ========================
# SIGNALS
# ========================
signal login_success(user: Dictionary)
signal login_failed(error: String)

signal logout_success()

signal register_success(user: Dictionary)
signal register_failed(error: String)

signal tasks_loaded(tasks: Dictionary)
signal task_saved(task_id: String, task_data: Dictionary)
signal task_deleted(task_id: String)

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)


# ========================
# AUTH
# ========================
func login(username: String, password: String) -> void:
	if _request_in_flight:
		return

	_request_in_flight = true

	_pending_request = "login"

	var url := "%s/rest/v1/rpc/login_user" % SUPABASE_URL

	var headers := _base_headers()

	var body := {
		"p_username": username,
		"p_password": password
	}

	_http.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)

func register(username: String, password: String) -> void:
	if _request_in_flight:
		return

	_request_in_flight = true
	_pending_request = "signup"

	var url := "%s/rest/v1/rpc/register_user" % SUPABASE_URL

	var headers := _base_headers()

	var body := {
		"p_username": username,
		"p_password": password
	}

	_http.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)

# ========================
# RESPONSE HANDLER
# ========================
func _on_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	var text := body.get_string_from_utf8()

	print("SUPABASE RESPONSE CODE:", response_code)
	print("SUPABASE BODY:", text)

	# Capture request type FIRST
	var finished_request := _pending_request

	# Reset request state immediately
	_pending_request = ""
	_request_in_flight = false

	# ---- 204 No Content ----
	if response_code == 204:
		match finished_request:
			"signup":
				register_success.emit()
			"logout":
				logout_success.emit()
		return

	# ---- Parse JSON (if any) ----
	var data = null
	if text != "":
		data = JSON.parse_string(text)

	# ---- Error handling ----
	if response_code < 200 or response_code >= 300:
		var msg := "Server error (%s)" % response_code
		if data is Dictionary and data.has("message"):
			msg = data["message"]
		_emit_error(msg)
		return

	# ---- Success dispatch ----
	match finished_request:
		"login":
			_handle_login(data)
		"signup":
			_handle_signup(data)
		"load_tasks":
			_handle_tasks_loaded(data)
		"save_task":
			_handle_task_saved(data)
		"update_task":
			_handle_task_updated(data)
		"delete_task":
			_handle_task_deleted()

# ========================
# HANDLERS
# ========================
func _handle_login(data) -> void:
	if data is Array and data.size() > 0:
		var user = data[0]

		current_user_id = str(user["id"])
		current_username = str(user["username"])

		login_success.emit(user)

		load_tasks()
	else:
		login_failed.emit("Invalid username or password")

func _handle_tasks_loaded(rows: Array) -> void:
	var tasks := {}

	for row in rows:
		var td := TaskData.new()
		td.name = row["data"]["name"]

		var subs: Array[String] = []
		for s in row["data"]["subtasks"]:
			subs.append(str(s))

		td.subtask_list = subs

		tasks[row["id"]] = td

	tasks_loaded.emit(tasks)

func logout():
	current_user_id = ""
	current_username = ""
	session_tasks.clear()

	if FileAccess.file_exists("user://session.json"):
		DirAccess.remove_absolute("user://session.json")

func _handle_signup(data) -> void:
	if data is Dictionary:
		register_success.emit(data)
	else:
		register_failed.emit("Could not create user")

func _handle_task_deleted() -> void:
	print("Task deleted from server")

func _emit_error(message: String) -> void:
	match _pending_request:
		"login":
			login_failed.emit(message)
		"signup":
			register_failed.emit(message)

func _handle_save_task(data):
	var task_id := str(data[0]["id"])
	session_tasks[task_id] = data[0]["data"]
	task_saved.emit(task_id, data[0]["data"])

func _handle_task_saved(data):
	if data is Array and data.size() > 0:
		var row = data[0]
		task_saved.emit(row["id"], null)

signal task_updated(task_id: String)

func _handle_task_updated(data) -> void:
	# Supabase PATCH usually returns an array of updated rows
	if data is Array and data.size() > 0:
		var row = data[0]
		task_updated.emit(row["id"])
	else:
		# Even if no row is returned, PATCH may still succeed
		task_updated.emit("")

# ========================
# HELPERS
# ========================
func _base_headers() -> PackedStringArray:
	return [
		"apikey: %s" % SUPABASE_ANON_KEY,
		"Authorization: Bearer %s" % SUPABASE_ANON_KEY,
		"Content-Type: application/json"
	]

func load_tasks() -> void:
	if _request_in_flight:
		return

	_request_in_flight = true
	_pending_request = "load_tasks"

	var url := "%s/rest/v1/tasks?user_id=eq.%s" % [
		SUPABASE_URL,
		current_user_id
	]

	_http.request(
		url,
		_base_headers(),
		HTTPClient.METHOD_GET
	)

func save_task(task_data: TaskData) -> void:
	if current_user_id == "":
		return

	_request_in_flight = true
	_pending_request = "save_task"

	var url := "%s/rest/v1/tasks" % SUPABASE_URL

	var headers := _base_headers()
	headers.append("Prefer: return=representation")
	
	var body := {
		"user_id": current_user_id,
		"data": {
			"name": task_data.name,
			"subtasks": task_data.subtask_list
		}
	}
	
	_http.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)
	
func update_task(task_id: String, task_data: TaskData) -> void:
	if task_id == "":
		push_error("update_task called with empty task_id")
		return

	_request_in_flight = true
	_pending_request = "update_task"

	var url := "%s/rest/v1/tasks?id=eq.%s" % [SUPABASE_URL, task_id]

	var headers := _base_headers()
	headers.append("Prefer: return=representation")

	var body := {
		"data": {
			"name": task_data.name,
			"subtasks": task_data.subtask_list
		}
	}

	_http.request(
		url,
		headers,
		HTTPClient.METHOD_PATCH,
		JSON.stringify(body)
	)

func delete_task(task_id: String) -> void:
	if _request_in_flight:
		return

	_request_in_flight = true
	_pending_request = "delete_task"

	var url := "%s/rest/v1/tasks?id=eq.%s" % [SUPABASE_URL, task_id]

	_http.request(
		url,
		_base_headers(),
		HTTPClient.METHOD_DELETE
	)

func _reset_request_state() -> void:
	_request_in_flight = false
	_pending_request = ""
