extends NPC

func _ready():
	MAX_MANA = 5
	
	tooltip_text = "He casts [b]AXE[/b]."
	tooltip_name = "Orc"
	
	super()
	
	spells = [Spell.Spell.new(Spell.SpellNames.FIREBALL)]
