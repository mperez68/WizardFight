extends NPC

func _ready():
	MAX_MANA = 5
	
	super()
	
	spells = [Spell.Spell.new(Spell.SpellNames.FIREBALL)]
