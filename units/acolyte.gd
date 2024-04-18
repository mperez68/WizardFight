extends NPC

func _ready():
	MAX_HP = 2
	
	super()
	
	tooltip_text = "A nerd. Not even a smart one."
	tooltip_name = "Acolyte"
	
	if randf() < 0.3:
		spells = [Spell.Spell.new(Spell.SpellNames.FIRE_BLAST)]
