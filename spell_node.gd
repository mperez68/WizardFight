extends Area2D

class_name SpellNode

signal hit

const Spell = preload("res://Spell.gd")
const ANIM_SPEED = 30

var anim: AnimatedSprite2D
var current_path: Array[Vector2]
var target: CharacterBody2D
var spell = Spell.Spell.new(Spell.SpellNames.MAGIC_MISSILE)	#Default to magic missile todo change to a rock

func _physics_process(delta):
	if current_path.is_empty():
		return
	
	var target_position = current_path.front()
	global_position = global_position.move_toward(target_position, ANIM_SPEED)
	
	if global_position == target_position:
		current_path.pop_front()
		
		if current_path.is_empty():
			anim.play("hit")

func start(target_body: CharacterBody2D, origin: Vector2, origin_height = 64):
	target = target_body
	rotation = origin.angle_to_point(target.global_position - Vector2(0, origin_height / 2))
	global_position += Vector2(1.2 * origin_height, 0).rotated(rotation) - Vector2(0, origin_height / 2)
	anim = find_children("*", "AnimatedSprite2D")[0]
	current_path.push_front(target.global_position - Vector2(0, origin_height / 2))
	
	anim.play("fly")
	visible = true


func _on_animation_finished():
	if anim and anim.animation == "hit":
		if randf() < spell.hit_chance:
			if randf() < spell.crit_chance:
				spell.damage *= 2
		
			target.add_hp(-spell.damage)
			if spell.status:
				target.effects.push_front(spell.status)
		
		hit.emit()
		queue_free()

