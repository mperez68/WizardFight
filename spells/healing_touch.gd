extends SpellNode

func _ready():
	spell = Spell.Spell.new(Spell.SpellNames.HEALING_TOUCH)

func start(target_body: CharacterBody2D, origin: Vector2, origin_height = 64):
	super(target_body, origin, origin_height)
	
	
	current_path.clear()
	anim.play("hit")
