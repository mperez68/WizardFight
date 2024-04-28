extends SpellNode

var caster_origin: Vector2

func _ready():
	spell = Spell.Spell.new(Spell.SpellNames.SWAP)
	show_di = false

func start(target_body: TacticsCharacter, origin: Vector2, origin_height = 64):
	caster_origin = origin
	super(target_body, origin)
	rotation = 0

func _on_animation_finished():
	if anim and anim.animation == "hit":
		
		var self_target = target.get_radius(0, target.tilemap.local_to_map(caster_origin))[0]
		self_target.global_position = global_position + Vector2(0, 32)
		target.global_position = caster_origin + Vector2(0, 32)
		
		hit.emit()
		anim.play("post_hit")
	if anim and anim.animation == "post_hit":
		queue_free()
