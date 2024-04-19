extends Node

class_name MainMenu

@onready var FULL_SIZE = DisplayServer.screen_get_size()
const WINDOW_SIZE = Vector2i(1440, 900)


# Title Screen
func _on_new_game_button_pressed():
	$TitleScreen.visible = false
	$NewGameScreen.visible = true

func _on_settings_button_pressed():
	$TitleScreen.visible = false
	$SettingsScreen.visible = true

func _on_exit_button_pressed():
	get_tree().quit()


# New Game Screen
func _on_level_1_button_pressed():
	get_tree().change_scene_to_file("res://level1.tscn")

func _on_level_2_button_pressed():
	pass # Replace with function body.

func _on_level_3_button_pressed():
	pass # Replace with function body.

func _on_player_button_pressed():
	pass # Replace with function body.


# Settings Screen
func _on_full_screen_button_pressed():
	full_screen(FULL_SIZE, WINDOW_SIZE)

static func full_screen(max_size: Vector2i, window_size: Vector2i):
	if (DisplayServer.window_get_mode()) == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		DisplayServer.window_set_size(window_size)
	else:
		DisplayServer.window_set_size(max_size)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_borderless_button_pressed():
	get_tree().root.borderless = !get_tree().root.borderless

func _on_back_button_pressed():
	$TitleScreen.visible = true
	$SettingsScreen.visible = false
	$NewGameScreen.visible = false
