extends NPC

func _ready():
	super()
	
	tooltip_text = "He's got band-aids in blue, green, [i]and[/i] pink."
	tooltip_name = "Cleric"
	
	spells.push_back(Spell.Spell.new(Spell.SpellNames.HEALING_TOUCH))
