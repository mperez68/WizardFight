extends NPC

func _ready():
	_max_hp = 1
	_max_mana = 1
	_max_speed = 2
	
	if !team:
		team = -2	# Reserved for zombies only.
	
	super()
	
	tooltip_text = "Reduce. Reuse. Recycle."
	tooltip_name = "Zombie"
	
	ai_profile = Ai.AiProfile.new(self, Ai.ProfileNames.ORC)
	
	spells = [Spell.Spell.new(Spell.SpellNames.SPEAR)]
