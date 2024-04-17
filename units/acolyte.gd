extends NPC

func _ready():
	super()
	
	tooltip_text = "A nerd. A common one, too, not even a smart one."
	tooltip_name = "Acolyte"
	
	if randf() < 0.3:
		spells = [Spell.Spell.new(Spell.SpellNames.FIRE_BLAST)]
