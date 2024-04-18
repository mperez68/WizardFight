extends Control

var sure_displayed = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_back_pressed():
	reset_return()
	$Menu.visible = true
	$Settings.visible = false

func _on_settings_pressed():
	$Menu.visible = false
	$Settings.visible = true

func _on_return_pressed():
	if sure_displayed:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://main_menu.tscn")
	else:
		sure_displayed = true
		$Menu/Return/Label.text = "ARE YOU SURE?"

func reset_return():
	sure_displayed = false
	$Menu/Return/Label.text = "RETURN TO MENU"

func _on_resume_pressed():
	reset_return()
	get_tree().paused = false
	visible = false