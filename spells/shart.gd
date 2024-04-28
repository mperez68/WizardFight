extends SpellNode

func _ready():
	spell = Spell.Spell.new(Spell.SpellNames.SHART)
	rotation = 0
	show_di = false

func start(target_body: TacticsCharacter, origin: Vector2, origin_height = 64):
	super(target_body, origin, origin_height - 32)
	visible = false
