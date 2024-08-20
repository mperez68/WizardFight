extends CanvasLayer

class Wizard:
	var name
	var char: TacticsCharacter
	var chosen_spells = []
	var chosen_items = []

enum select { SPELLS, ITEMS }

@onready var level = $".."

@export var spells_start = 0
@export var spells_end = 0
@export var items_start = 0
@export var items_end = 0

const sp = preload("res://spells/Spell.gd")
const it = preload("res://items/item.gd")

const generic_icon = preload("res://assets/item.png")

# Buttons
var selection_buttons = []
var selected_option_buttons = []
var wizard_buttons = []
var faded = Color(1, 1, 1, 0.60784316062927)
var opaque = Color(1, 1, 1, 1)

# Data Storage
var wizards = []
var active_wizard_pointer = 0
var select_type = select.SPELLS

func _ready():
	level.update_characters()
	
	if !spells_start and !spells_end and !items_start and !items_end:
		spells_end = sp.SpellNames.size()
		items_end = it.ItemNames.size()
	
	if !items_start and !items_end:
		$BG/SpItSwitch.visible = false
	
	for i in level.characters.size():
		if level.characters[i].name.contains("Player"):
			var w = Wizard.new()
			w.char = level.characters[i]
			wizards.push_back(w)
	
	# Populate button arrays
	var temp = $BG.find_children("*", "TextureButton")
	
	for i in temp.size():
		if temp[i].name.contains("Selection"):
			selection_buttons.push_back(temp[i])
		elif temp[i].name.contains("SelectedWizard"):
			wizard_buttons.push_back(temp[i])
			if wizards.size() < wizard_buttons.size():
				temp[i].visible = false
		elif temp[i].name.contains("SelectedOption"):
			selected_option_buttons.push_back(temp[i])
			
	update_options()

# Button press methods
func _on_go_button_pressed():
	for i in wizards.size():
		if !wizards[i].chosen_spells.size() or (!wizards[i].chosen_items.size() and items_end > 0):
			print("Empty spells and/or items list")
			return
	
	visible = false
	$"../HUD".visible = true
	$"..".is_playing_full_song = true
	$DoubleClick.play()
	
	for i in wizards.size():
		for j in wizards[i].chosen_spells.size():
			wizards[i].char.spells.push_back(wizards[i].chosen_spells[j])
		for k in wizards[i].chosen_items.size():
			wizards[i].char.items.push_back(wizards[i].chosen_items[k])
	
	level.inc_turn()

func _on_view_map_button_pressed():
	$Click.play()
	$BG.visible = !$BG.visible

func _on_selection_pressed(key):
	$Click.play()
	var sel
	
	if select_type == select.SPELLS:
		sel = sp.Spell.new(key)
	else:
		sel = it.Item.new(key)
	
	if get_arr().size() < selected_option_buttons.size():
		for i in get_arr().size():
			if get_arr()[i].name == sel.name:
				return
		get_arr().push_back(sel)
	else:
		print("can't push spell %s" % [sel.name])
	update_selections()

func _on_selected_wizard_pressed(wizard_key):
	$DoubleClick.play()
	if wizards.size() > wizard_key:
		wizard_buttons[active_wizard_pointer].find_children("*", "Label")[0].uppercase = false
		active_wizard_pointer = wizard_key
		wizard_buttons[active_wizard_pointer].find_children("*", "Label")[0].uppercase = true
	update_selections()

func _on_selected_option_pressed(button_key):
	$Click.play()
	if button_key < get_arr().size():
		get_arr().remove_at(button_key)
	update_selections()

func _on_sp_it_switch_pressed():
	$DoubleClick.play()
	select_type = (select_type + 1) % 2
	update_selections()
	update_options()

# Utility
func update_selections():
	var arr = get_arr()
	for i in selected_option_buttons.size():
		if arr.size() > i:
			selected_option_buttons[i].texture_normal = arr[i].icon
			selected_option_buttons[i].find_children("*", "Label")[0].text = arr[i].name
		else:
			selected_option_buttons[i].texture_normal = generic_icon
			selected_option_buttons[i].find_children("*", "Label")[0].text = ""

func update_options():
	var all_options
	if select_type == select.SPELLS:
		all_options = sp.SpellNames.values().slice(spells_start, spells_end)
		$BG/SpItSwitch/VBoxContainer/Label.text = "Select Items"
	else:
		all_options = it.ItemNames.values().slice(items_start, items_end)
		$BG/SpItSwitch/VBoxContainer/Label.text = "Select Spells"
	
	var temp
	for i in selection_buttons.size():
		temp = null
		
		if all_options.has(i):
			if select_type == select.SPELLS:
				temp = sp.Spell.new(i)
			else:
				temp = it.Item.new(i)
			
		if temp != null:
			selection_buttons[i].find_children("*", "Label")[0].text = temp.name
			selection_buttons[i].texture_normal = temp.icon
			selection_buttons[i].modulate = opaque
			selection_buttons[i].disabled = false
		else:
			selection_buttons[i].find_children("*", "Label")[0].text = ""
			selection_buttons[i].texture_normal = generic_icon
			selection_buttons[i].modulate = faded
			selection_buttons[i].disabled = true

func get_arr():
	if select_type == select.SPELLS:
		return wizards[active_wizard_pointer].chosen_spells
	else:
		return wizards[active_wizard_pointer].chosen_items


func _on_selection_mouse_entered(key):
	var option
	
	if selection_buttons[key].disabled == true:
		return
	
	if select_type == select.SPELLS:
		if sp.SpellNames.size() <= key:
			return
		option = sp.Spell.new(key)
	else:
		if it.ItemNames.size() <= key:
			return
		option = it.Item.new(key)
	
	$BG/LargeIcon.texture = option.icon
	$BG/Tooltip/VBoxContainer/Label.append_text("[b]%s: [/b]\n%s mana, %s range, %s damage" % [option.name, option.cost, option.range, option.damage])
	if option.crit_chance:
		$BG/Tooltip/VBoxContainer/Label.append_text(", %s crit" % [option.crit_chance])
	if option.radius:
		$BG/Tooltip/VBoxContainer/Label.append_text(", %s radius" % [option.radius])
	$BG/Tooltip/VBoxContainer/Label.append_text("\n%s" % [option.tooltip])

func _on_selection_mouse_exited():
	$BG/LargeIcon.texture = generic_icon
	$BG/Tooltip/VBoxContainer/Label.clear()
