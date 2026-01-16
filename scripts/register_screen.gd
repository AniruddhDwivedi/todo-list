extends Control

@onready var username_input: LineEdit = $Layout/App/LoginView/LoginSubLayout/DetailLayout/UserNameEntry/UserNameEntry
@onready var password_input: LineEdit = $Layout/App/LoginView/LoginSubLayout/DetailLayout/HBoxContainer/PasswordEntry
@onready var register_button: Button = $Layout/App/LoginView/LoginSubLayout/ButtonLayout/RegisterButton
@onready var back_button: Button = $Layout/App/LoginView/LoginSubLayout/ButtonLayout/SignInButton # optional
@onready var login_screen = "res://scenes/login_screen.tscn"
@onready var success_dialog = $SuccessDialog
@onready var failure_dialog = $FailureDialog

func _ready() -> void:
	success_dialog.visible = false
	failure_dialog.visible = false
	register_button.pressed.connect(_on_register_pressed)
	back_button.pressed.connect(_on_sign_in_button_pressed)
	
	supabase.register_success.connect(_on_register_success)
	supabase.register_failed.connect(_on_register_failed)

func _on_register_pressed() -> void:
	register_button.disabled = true

	supabase.register(
		username_input.text,
		password_input.text
	)

func _on_register_success() -> void:
	register_button.disabled = false
	print("Registration successful")
	success_dialog.visible = true
	success_dialog.name_label.set_text("Registered user: " + username_input.text)

func _on_register_failed(err: String) -> void:
	register_button.disabled = false
	print("Register error:", err)
	failure_dialog.visible = true
	success_dialog.name_label.set_text("Registration error: " + username_input.text + " is an existing username")

func _on_sign_in_button_pressed() -> void:
	SceneSwitcher.change_scene(login_screen)
