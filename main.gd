extends Node2D

var turn_counter = 1
var characters = []
var pending_removal_pointers = []
var turn_pointer = -1

const Spell = preload("res://spells/Spell.gd")
const Item = preload("res://items/item.gd")

@onready var tilemap = $TileMap
@onready var camera = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	update_characters()
	inc_turn()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if characters[turn_pointer] and camera.position != characters[turn_pointer].focus:
		camera.position = characters[turn_pointer].focus

func inc_turn():
	turn_pointer += 1
	#character turns
	if characters and turn_pointer < characters.size():
		# activate/deactivate HUD
		if characters[turn_pointer].name.contains("Player"):
			set_hud(true)
		else:
			set_hud(false)
		populate_spells(characters[turn_pointer].spells)
		populate_items(characters[turn_pointer].items)
		# end/start appropriate turns
		characters[(turn_pointer - 1) % characters.size()].end_turn()
		characters[turn_pointer].start_turn()
	else:
		turn_pointer = -1
		turn_counter += 1
		$HUD/TurnCounter.text = str(turn_counter)
		# Clear dead characters
		pending_removal_pointers.sort()
		while !pending_removal_pointers.is_empty():
			characters.remove_at(pending_removal_pointers.pop_back())
		# Recur
		inc_turn()

func state_check():
	for i in characters.size():
		if !characters[i].name.contains("Player") and !characters[i].is_dead:
			return
	
	# Only gets to this point if above loop didn't break
	set_hud(false)
	$HUD/CenterText.visible = true

func update_characters():
	characters = find_children("*", "CharacterBody2D")

func set_hud(state = true, filter = "Button"):
	# Set filters enable/disable status
	var buttons = find_children("*", "Button")
	for i in buttons.size():
		if buttons[i].name.contains(filter):
			buttons[i].disabled = !state
			if state and buttons[i].get_child_count() > 0:
				buttons[i].find_child("*").modulate = "ffffffff"
			elif buttons[i].get_child_count() > 0:
				buttons[i].find_child("*").modulate = "ffffff7f"
	
	set_spells(characters[turn_pointer].spells)
	set_items(characters[turn_pointer].items)

func set_spells(spells: Array[Spell.Spell]):
	var spell_buttons = get_buttons("Spell")
	
	for i in spells.size():
		if characters[turn_pointer].mana < spells[i].cost:
			spell_buttons[i].disabled = true
			spell_buttons[i].find_child("*").modulate = "ffffff7f"

func set_items(items: Array[Item.Item]):
	var item_buttons = get_buttons("Item")
	
	for i in items.size():
		if characters[turn_pointer].mana < items[i].cost:
			item_buttons[i].disabled = true
			item_buttons[i].find_child("*").modulate = "ffffff7f"

func populate_spells(spells: Array[Spell.Spell]):
	# Find spell buttons
	var spell_buttons = get_buttons("Spell")
	# set [in]visible and name buttons
	for i in spell_buttons.size():
		if i < spells.size():
			spell_buttons[i].visible = true
			spell_buttons[i].find_child("*").find_child("*").text = spells[i].name
		else:
			spell_buttons[i].visible = false

func populate_items(items: Array[Item.Item]):
	var item_buttons = get_buttons("Item")
	# set [in]visible and name buttons
	for i in item_buttons.size():
		if i < items.size():
			item_buttons[i].visible = true
			item_buttons[i].find_child("*").find_child("*").text = str(items[i].quantity, " ", items[i].name)
		else:
			item_buttons[i].visible = false

func get_buttons(filter: String):
	var buttons = find_children("*", "Button")
	var filter_buttons: Array[Button]
	for i in buttons.size():
		if buttons[i].name.contains(filter):
			filter_buttons.push_back(buttons[i])
	return filter_buttons

func _on_pass_turn_pressed():
	inc_turn()

func _on_move_pressed():
	if turn_pointer >= 0 and characters[turn_pointer].name.contains("Player"):
		characters[turn_pointer].button_move()

func _on_spell_pressed(selected_spell):
	if turn_pointer >= 0 and characters[turn_pointer].name.contains("Player"):
		characters[turn_pointer].button_shoot(selected_spell)

func _on_item_pressed(selected_item):
	if turn_pointer >= 0 and characters[turn_pointer].name.contains("Player"):
		characters[turn_pointer].button_item(selected_item)
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		var result = $Camera2D.zoom.x
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			result = min($Camera2D.zoom.x + 0.1, 1.5)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			result = max($Camera2D.zoom.x - 0.1, 0.5)
		$Camera2D.zoom = Vector2(result, result)

func _on_button_mouse_entered(num, type):
	$HUD/ToolTip/VBoxContainer/Label.clear()
	if (type == "spell"):
		var spell = characters[turn_pointer].spells[num]
		$HUD/ToolTip/VBoxContainer/Label.append_text("[b]%s: [/b]\n%s mana, %s damage, %s crit\n%s" % [spell.name, str(spell.cost), str(spell.damage), str(spell.crit_chance), spell.tooltip])
	
	if (type == "item"):
		var item = characters[turn_pointer].items[num]
		$HUD/ToolTip/VBoxContainer/Label.append_text("[b]%s: [/b]\n%s" % [item.name, item.tooltip])

func _on_button_mouse_exited():
	$HUD/ToolTip/VBoxContainer/Label.clear()
