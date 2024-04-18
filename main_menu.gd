extends Node

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
	pass # Replace with function body.


func _on_borderless_button_pressed():
	pass # Replace with function body.



func _on_back_button_pressed():
	$TitleScreen.visible = true
	$SettingsScreen.visible = false
	$NewGameScreen.visible = false
