extends Control

@onready var register_button = $App/Layout/ButtonLayout/RegisterButtonField/RegisterButton
@onready var login_button = $App/Layout/ButtonLayout/LoginButtonField/LoginButton
@onready var exit_button = $App/Layout/ExitButtonContainer/ExitButton

@onready var login_scene = "res://scenes/login_screen.tscn"
@onready var register_scene = "res://scenes/register_screen.tscn"

func _ready() -> void:
	register_button.pressed.connect(_on_register_button_pressed)
	login_button.pressed.connect(_on_login_button_pressed)
	exit_button.pressed.connect(exit_sequence)

func exit_sequence():
	get_tree().quit()

func _on_register_button_pressed() -> void:
	SceneSwitcher.change_scene(register_scene)

func _on_login_button_pressed() -> void:
	SceneSwitcher.change_scene(login_scene)
