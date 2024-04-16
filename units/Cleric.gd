extends NPC

func _ready():
	super()
	
	spells.push_back(Spell.Spell.new(Spell.SpellNames.HEALING_TOUCH))
