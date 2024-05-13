extends Area2D

class_name ItemNode

signal hit

const Item = preload("res://items/item.gd")
const di = preload("res://spells/damage_indicator.tscn")
const ANIM_SPEED = 30

var anim: AnimatedSprite2D
var current_path: Array[Vector2]
var target: CharacterBody2D
var item = Item.Item.new(Item.ItemNames.HEALTH_POTION)

func _physics_process(_delta):
	if current_path.is_empty():
		return
	
	var target_position = current_path.front()
	global_position = global_position.move_toward(target_position, ANIM_SPEED)
	
	if global_position == target_position:
		current_path.pop_front()
		
		if current_path.is_empty():
			$"../Hit".play()
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
		#Damage Indicator
		var damage_indicator = di.instantiate()
		get_parent().add_child(damage_indicator)
		if randf() < item.hit_chance:
			target.add_hp(-item.damage)
			#Damage Indicator
			damage_indicator.start(target.global_position + Vector2(0, -64), str(item.damage), false)
			if item.status:
				target.effects.push_front(item.status)
				$"../Effect".play()
		else:
			#Damage Indicator (miss)
			$"../Miss".play()
			damage_indicator.start(target.global_position + Vector2(0, -64), "MISS!", false)
		
		hit.emit()
		queue_free()
