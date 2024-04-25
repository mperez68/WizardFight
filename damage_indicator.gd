extends Area2D

class_name DamageIndicator

var _blue = Color(0, 0, 1)
var _red = Color(1, 0, 0)

func start(position_start: Vector2, damage: String, is_crit: bool):
	global_position = position_start
	$Label.text = damage
	position.x -= $Label.size.x / 2
	if is_crit:
		$Label.set("theme_override_colors/font_color",_red)
		$Label.text = $Label.text + "!"
	if damage.contains("-"):
		$Label.set("theme_override_colors/font_color",_blue)
		$Label.text = $Label.text.right(1)
	$AnimationPlayer.play("fade")
	visible = true

func _on_animation_finished():
	queue_free()
