extends NPC

func _ready():
	_max_hp = 20
	_max_mana = 10
	_hp_regen = 1
	_mana_regen = 2
	
	super()
	
	tooltip_text = "Oh shit he's got a tazer"
	tooltip_name = "High Priest"
	
	ai_profile = Ai.AiProfile.new(self, Ai.ProfileNames.SUPPORT)
	
	spells = [Spell.Spell.new(Spell.SpellNames.SHOCKING_GRASP),
		Spell.Spell.new(Spell.SpellNames.LIGHTNING_BOLT),
		Spell.Spell.new(Spell.SpellNames.HEALING_TOUCH)]
