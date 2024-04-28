extends SpellNode

func _ready():
	spell = Spell.Spell.new(Spell.SpellNames.ESPRESSO)
	target.speed += 2
	show_di = false
