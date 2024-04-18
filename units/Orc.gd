extends NPC

func _ready():
	MAX_HP = 4
	MAX_MANA = 5
	
	super()
	
	tooltip_text = "He casts [b]AXE[/b]."
	tooltip_name = "Orc"
	
	spells = [Spell.Spell.new(Spell.SpellNames.FIREBALL)]
