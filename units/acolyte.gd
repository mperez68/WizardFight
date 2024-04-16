extends NPC

func _ready():
	super()
	
	if randf() < 0.3:
		spells = [Spell.Spell.new(Spell.SpellNames.FIRE_BLAST)]
