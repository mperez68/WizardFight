extends SpellNode

func _ready():
	spell = Spell.Spell.new(Spell.SpellNames.TELEPORT)
	show_di = false

func _on_animation_finished():
	if anim and anim.animation == "hit":
		
		target.global_position = global_position + Vector2(0, 32)
		
		hit.emit()
		anim.play("post_hit")
	if anim and anim.animation == "post_hit":
		queue_free()
