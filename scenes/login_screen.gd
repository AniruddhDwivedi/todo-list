extends Control

@onready var http: HTTPRequest = $HTTPRequest
@onready var email_input: LineEdit = $Layout/App/LoginView/LoginSubLayout/DetailLayout/UserNameEntry/UserNameEntry
@onready var password_input: LineEdit = $Layout/App/LoginView/LoginSubLayout/DetailLayout/HBoxContainer/PasswordEntry
@onready var login_button: Button = $Layout/App/LoginView/LoginSubLayout/ButtonLayout/SignInButton
@onready var register_button: Button = $Layout/App/LoginView/LoginSubLayout/ButtonLayout/RegisterButton
@onready var register_scene = "res://scenes/register_screen.tscn"
@onready var previous_scene = "res://scenes/main.tscn"
@onready var main_scene = "res://scenes/main_window.tscn"
@onready var failureDialog = $FailD

func _ready() -> void:
	failureDialog.visible = false
	login_button.pressed.connect(_on_login_pressed)
	register_button.pressed.connect(_on_register_button_pressed)

	supabase.login_success.connect(_on_login_success)
	supabase.login_failed.connect(_on_login_failed)

func _on_login_pressed():
	login_button.disabled = true
	supabase.login(
		email_input.text,
		password_input.text
	)

func _on_login_failed(err):
	login_button.disabled = false
	print(err)
	failureDialog.visible = true

func _on_login_success(user):
	login_button.disabled = false
	print("Logged in:", user["username"])
	SceneSwitcher.change_scene(main_scene)

func _on_register_button_pressed() -> void:
	SceneSwitcher.change_scene(register_scene)
