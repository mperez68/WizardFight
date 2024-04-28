extends Area2D

class_name SpellNode

signal hit

const Spell = preload("res://spells/Spell.gd")
const di = preload("res://spells/damage_indicator.tscn")
const ef = preload("res://status/StatusEffect.gd")
const ANIM_SPEED = 30

var anim: AnimatedSprite2D
var current_path: Array[Vector2]
var target: TacticsCharacter
var spell = Spell.Spell.new(Spell.SpellNames.ROCK)
var show_di = true

func _physics_process(_delta):
	if current_path.is_empty():
		return
	
	var target_position = current_path.front()
	global_position = global_position.move_toward(target_position, ANIM_SPEED)
	
	if global_position == target_position:
		current_path.pop_front()
		
		if current_path.is_empty():
			anim.play("hit")
			visible = true

func start(target_body: TacticsCharacter, origin: Vector2, origin_height = 64):
	target = target_body
	rotation = origin.angle_to_point(target.global_position - Vector2(0, origin_height / 2))
	global_position += Vector2(1.2 * origin_height, 0).rotated(rotation) - Vector2(0, origin_height / 2)
	anim = find_children("*", "AnimatedSprite2D")[0]
	current_path.push_front(target.global_position - Vector2(0, origin_height / 2))
	
	anim.play("fly")
	visible = true

func start_no_target(caster: TacticsCharacter, target_loc: Vector2, origin_height = 64):
	target = caster
	global_position += Vector2(1.2 * origin_height, 0) - Vector2(0, origin_height / 2)
	anim = find_children("*", "AnimatedSprite2D")[0]
	current_path.push_front(target_loc - Vector2(0, origin_height / 2))
	
	anim.play("fly")
	visible = true


func _on_animation_finished():
	if anim and anim.animation == "hit":
		#Damage Indicator
		var damage_indicator = di.instantiate()
		get_parent().add_child(damage_indicator)
		
		#Check if countered by spellshield
		for a in target.effects.size():
			if target.effects[a].enum_key == ef.EffectNames.SPELLSHIELD:
				target.effects.remove_at(a)
				damage_indicator.start(target.global_position + Vector2(0, -64), "NO", true)
				hit.emit()
				queue_free()
				return
		
		#Run odds for hit/crit
		if randf() < spell.hit_chance:
			var is_crit = false
			if randf() < spell.crit_chance:
				spell.damage *= 2
				is_crit = true
		
			target.add_hp(-spell.damage)
			#Damage Indicator
			if show_di:
				damage_indicator.start(target.global_position + Vector2(0, -64), str(spell.damage), is_crit)
			if spell.status:
				target.effects.push_front(spell.status)
		else:
			#Damage Indicator (miss)
			damage_indicator.start(target.global_position + Vector2(0, -64), "MISS!", false)
		
		hit.emit()
		queue_free()

