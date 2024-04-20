extends TacticsCharacter

class_name NPC

var Ai = preload("res://units/ai_profile.gd")

var tooltip_text = "This is tooltip text!"
var tooltip_name = "NPC"

var ai_profile

# overrides
func _ready():
	super()
	ai_profile = Ai.AiProfile.new(self, Ai.ProfileNames.MINION)
	
	if (!team):
		team = 1

func start_turn():
	super()
	
	if is_dead:
		level.inc_turn()
		return
	
	await get_tree().create_timer(1).timeout
	ai_profile.turn_process()


# Tooltip fill/clear
func populate_tooltip():
	var icons = level.get_tooltip_icons("Spell")
	# set [in]visible and name buttons
	for i in icons.size():
		if i < spells.size():
			icons[i].visible = true
			icons[i].texture = spells[i].icon
		else:
			icons[i].visible = false

func clear_tooltip():
	var icons = level.get_tooltip_icons("Spell")
	for i in icons.size():
		icons[i].visible = false

func _on_mouse_entered():
	populate_tooltip()
	level.tooltip.clear()
	level.tooltip.append_text("[b]%s[/b]\n" % [tooltip_name])
	level.tooltip.append_text(tooltip_text)
	if level.characters[level.turn_pointer].name.contains("Player"):
		tilemap.draw_weighted_range(z_index, global_position, _max_speed, true)

func _on_mouse_exited():
	clear_tooltip()
	level.tooltip.clear()
	if level.characters[level.turn_pointer].name.contains("Player"):
		level.characters[level.turn_pointer].set_highlight()
