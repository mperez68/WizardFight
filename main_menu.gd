extends Node

class_name MainMenu

@onready var FULL_SIZE = DisplayServer.screen_get_size()
const WINDOW_SIZE = Vector2i(1440, 900)
const SAVE_PATH = "user://level.save"
const levels = ["res://levels/level1.tscn", "res://levels/level2.tscn", "res://levels/level3.tscn", "res://levels/level4.tscn", "res://levels/level5.tscn", "res://levels/level6.tscn"]

var level_buttons = []

func _ready():
	level_buttons = get_buttons("Level")

# Title Screen
func _on_new_game_button_pressed():
	$Click.play()
	$TitleScreen.visible = false
	$NewGameScreen.visible = true
	
	# Populate
	var max_level = 1
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		max_level = file.get_8()
	for i in level_buttons.size():
		if i < max_level:
			level_buttons[i].visible = true
		else:
			level_buttons[i].visible = false

func _on_settings_button_pressed():
	$Click.play()
	$TitleScreen.visible = false
	$SettingsScreen.visible = true

func _on_exit_button_pressed():
	$DoubleClick.play()
	await get_tree().create_timer(1).timeout
	get_tree().quit()

func get_buttons(filter: String):
	var buttons = find_children("*", "TextureButton")
	@warning_ignore("unassigned_variable")
	var filter_buttons: Array[TextureButton]
	for i in buttons.size():
		if buttons[i].name.contains(filter):
			filter_buttons.push_back(buttons[i])
	return filter_buttons

# New Game Screen
func _on_level_button_pressed(key):
	if key < levels.size():
		$Click.play()
		get_tree().change_scene_to_file(levels[key])


# Settings Screen
func _on_full_screen_button_pressed():
	$Click.play()
	full_screen(FULL_SIZE, WINDOW_SIZE)

static func full_screen(max_size: Vector2i, window_size: Vector2i):
	if (DisplayServer.window_get_mode()) == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		DisplayServer.window_set_size(window_size)
	else:
		DisplayServer.window_set_size(max_size)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_borderless_button_pressed():
	$Click.play()
	get_tree().root.borderless = !get_tree().root.borderless

func _on_back_button_pressed():
	$Click.play()
	$TitleScreen.visible = true
	$SettingsScreen.visible = false
	$NewGameScreen.visible = false

func _on_audio_finished():
	$intro.play()
