extends NPC

func _ready():
	_max_hp = 1
	_max_mana = 1
	
	if !team:
		team = -1	# Reserved for orcs only.
	
	super()
	
	tooltip_text = "The only thing he casts are dispersions."
	tooltip_name = "Orc"
	
	ai_profile = Ai.AiProfile.new(self, Ai.ProfileNames.ORC)
	
	spells = [Spell.Spell.new(Spell.SpellNames.SPEAR), Spell.Spell.new(Spell.SpellNames.ROCK)]
