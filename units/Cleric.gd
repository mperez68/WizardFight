extends NPC

func _ready():
	_max_speed += 1
	super()
	
	tooltip_text = "He's got band-aids in blue, green, [i]and[/i] pink."
	tooltip_name = "Cleric"
	
	ai_profile = Ai.AiProfile.new(self, Ai.ProfileNames.SUPPORT)
	
	spells.push_back(Spell.Spell.new(Spell.SpellNames.HEALING_TOUCH))
