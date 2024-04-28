extends SpellNode

const Zombie = preload("res://units/zombie.tscn")

func _ready():
	spell = Spell.Spell.new(Spell.SpellNames.RAISE_DEAD)
	show_di = false

func _on_animation_finished():
	if anim and anim.animation == "hit":
		var z = Zombie.instantiate()
		z.global_position = global_position - Vector2(0, -32)
		target.level.characters.push_back(z)
		target.add_sibling(z)
		z.set_team(target.team)
		hit.emit()
		anim.play("post_hit")
	if anim and anim.animation == "post_hit":
		queue_free()
