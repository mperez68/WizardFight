extends Control

@onready var FULL_SIZE = DisplayServer.screen_get_size()
const WINDOW_SIZE = Vector2i(1440, 900)

@onready var level = $"../../.."
@onready var click = $"../../../Click"
@onready var double_click = $"../../../DoubleClick"

var sure_displayed = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_back_pressed():
	click.play()
	reset_return()
	$Menu.visible = true
	$Settings.visible = false
	

func _on_settings_pressed():
	click.play()
	$Menu.visible = false
	$Settings.visible = true

func _on_return_pressed():
	if sure_displayed:
		double_click.play()
		get_tree().paused = false
		get_tree().change_scene_to_file("res://main_menu.tscn")
	else:
		click.play()
		sure_displayed = true
		$Menu/Return/Label.text = "ARE YOU SURE?"

func reset_return():
	sure_displayed = false
	$Menu/Return/Label.text = "RETURN TO MENU"

func _on_resume_pressed():
	click.play()
	reset_return()
	level.is_playing_full_song = true
	get_tree().paused = false
	visible = false

func _on_full_screen_pressed():
	click.play()
	MainMenu.full_screen(FULL_SIZE, WINDOW_SIZE)

func _on_borderless_pressed():
	click.play()
	get_tree().root.borderless = !get_tree().root.borderless
