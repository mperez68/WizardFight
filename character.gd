extends CharacterBody2D

class_name TacticsCharacter

const ANIM_SPEED = 4
const Spell = preload("res://Spell.gd")
const Item = preload("res://item.gd")
const Effect = preload("res://StatusEffect.gd")
var ADJ_VECTORS: Array[Vector2]

@onready var tilemap = $"../TileMap"
@onready var anim = $AnimatedSprite2D
@onready var main = $".."

@export var MAX_SPEED = 3
@export var MAX_ATTACKS = 1
@export var MAX_ITEM_USES = 1
@export var MAX_HP = 3
@export var MAX_MANA = 2
@export var HP_REGEN = 0
@export var MANA_REGEN = 1

var start: Vector2i
var current_path: Array[Vector2i]
var focus = Vector2(global_position)

var hp = MAX_HP
var mana = MAX_MANA
var speed = MAX_SPEED
var attacks = MAX_ATTACKS
var item_uses = MAX_ITEM_USES

var spells: Array[Spell.Spell]
var spell_pointer = 0
var items: Array[Item.Item]
var item_pointer = 0
var effects: Array[Effect.StatusEffect]

var is_active = false
var is_dead = false
var active_missiles = 0

# Overrides
func _ready():
	var vec_x = tilemap.tile_set.tile_size.x / 2
	var vec_y = tilemap.tile_set.tile_size.y / 2
	ADJ_VECTORS = [Vector2(vec_x, vec_y), Vector2(-vec_x, vec_y),
	Vector2(vec_x, -vec_y), Vector2(-vec_x, -vec_y)]
	
	hp = MAX_HP
	mana = MAX_MANA
	
	if !start:
		start = tilemap.local_to_map(global_position)
	
	spells.push_front(Spell.Spell.new(Spell.SpellNames.MAGIC_MISSILE))
	
	global_position = tilemap.map_to_local(start)
	tilemap.astar[z_index].set_point_solid(get_grid_position())
	
	$Info/HPTextLevel.text = str(hp)
	$Info/HPTextMax.text = str(hp)
	$Info/HPBar.value = hp
	$Info/HPBar.max_value = hp
	
	$Info/ManaTextLevel.text = str(mana)
	$Info/ManaTextMax.text = str(mana)
	$Info/ManaBar.value = mana
	$Info/ManaBar.max_value = mana

func _physics_process(delta):
	if is_dead:
		anim.play("dead")
		
		# Set camera focus
		focus = global_position
		return
	
	if (anim.animation == "cast" and anim.is_playing()) or active_missiles > 0:
		return
	
	if current_path.is_empty():
		anim.play("stand")
	
		# Set camera focus
		focus = global_position
		return
	
	# Move towards next tile
	var target_position = tilemap.map_to_local(current_path.front())
	global_position = global_position.move_toward(target_position, ANIM_SPEED)
	
	# Update animation when walking
	if global_position.angle_to(target_position) < 0:
		anim.play("walk_right")
	else:
		anim.play("walk_left")
	
	# update path when location is reached
	if global_position == target_position:
		var temp = current_path.pop_front()
		speed -= tilemap.astar[z_index].get_point_weight_scale(temp)
		
		vert_check(current_path)

# Util
func set_hp(value):
	hp = value
	$Info/HPTextLevel.text = str(hp)
	$Info/HPBar.value = hp
	
	if hp <= 0 and !is_dead:
		is_dead = true
		set_hp(0)
		set_mana(0)
		for i in main.characters.size():
			if main.characters[i] == self:
				main.pending_removal_pointers.push_front(i)
				main.state_check()
				return

func add_hp(value):
	set_hp(min(hp + value, MAX_HP))

func set_mana(value):
	mana = value
	$Info/ManaTextLevel.text = str(mana)
	$Info/ManaBar.value = mana

func add_mana(value):
	set_mana(min(mana + value, MAX_MANA))

func set_active(new_state = true):
	is_active = new_state

func can_cast(pointer = null):
	var temp_pointer = spell_pointer
	if !pointer:
		for i in spells.size():
			if spells[i].cost <= mana:
				spell_pointer = i
				break
	return attacks > 0 and mana >= spells[temp_pointer].cost

func shoot_radius(origin: Vector2i, layer: int, pointer = spell_pointer): # todo add hit chance and crit chance
	var spell = spells[pointer]
	if spell.radius == 0:
		print("Cannot cast! Spell Radius == ", spell.radius)
		return
	
	var targets: Array[CharacterBody2D] = []
	var rough_range_start = origin - Vector2i(spell.radius, spell.radius)
	for i in 2 * spell.radius + 1:
		for j in 2 * spell.radius + 1:
			var temp_loc = Vector2i(i, j) + rough_range_start
			# select any targets at location
			for k in main.characters.size():
				if main.characters[k].get_grid_position() == temp_loc:
					targets.push_back(main.characters[k])
	
	shoot(null, targets, pointer)

func _on_hit():
	active_missiles -= 1
	if active_missiles == 0:
		focus = global_position
	
func shoot(target: CharacterBody2D = null, targets: Array[CharacterBody2D] = [], pointer = spell_pointer): # todo add hit chance and crit chance
	if !can_cast(pointer):
		print("Cannot cast! ", mana, " < ", spells[pointer].cost, " :: attacks == ", attacks)
		return
	
	if target or targets.size():
		anim.play("cast")
		add_mana(-spells[pointer].cost)
		attacks -= 1
		
	if target:
		var missile = spells[pointer].spell_node.instantiate()
		missile.start(target, global_position)
		active_missiles += 1
		missile.hit.connect(_on_hit)
		add_child(missile)
		
	for i in targets.size():
		var missile = spells[pointer].spell_node.instantiate()
		missile.start(targets[i], global_position)
		active_missiles += 1
		missile.hit.connect(_on_hit)
		add_child(missile)
	
	# change focus
	var focus_targets = targets
	focus_targets.push_front(self)
	if target:
		focus_targets.push_front(target)
	var temp = Vector2()
	for i in focus_targets.size():
		temp += focus_targets[i].position
	temp = temp / focus_targets.size()
	focus = temp

func use_item(pointer = item_pointer, target: CharacterBody2D = null): # todo select target for ranged items
	if !items[pointer].range:
		target = self
	elif !target:
		print("Can't Use Item! target == ", target, " :: items[pointer].range == ", items[pointer].range)
		return
	
	target.add_hp(-items[pointer].damage)
	target.add_mana(-items[pointer].cost)
	# todo add sprite/animation
	
	items[pointer].quantity -= 1
	if items[pointer].quantity <= 0:
		items.remove_at(pointer)
	item_uses -= 1
	main.populate_items(items)

func get_grid_position():
	return tilemap.local_to_map(global_position)

func vert_check(current_path):
	if current_path.size() == 1 and tilemap.is_stairs(z_index, current_path.front()):
		climb()
	elif current_path.size() == 1 and tilemap.is_drop(z_index, current_path.front()):
		drop()

func climb():
	z_index += 1
	for i in current_path.size():
		current_path[i] -= Vector2i(1, 1)
	
	var stairs_vector = tilemap.get_cell_tile_data(z_index, current_path[0]).get_custom_data("climb_direction")
	
	if current_path.size() == 1:
		current_path.push_back(current_path[0] + stairs_vector)

func drop():
	pass

# Turn stepping
func start_turn():
	if is_dead:
		return
	
	# Reset resources
	speed = MAX_SPEED
	attacks = MAX_ATTACKS
	item_uses = MAX_ITEM_USES
	set_active(true)
	add_hp(HP_REGEN)
	add_mana(MANA_REGEN)
	
	# Effect modifiers
	for i in effects.size():
		effects[i].on_start.call(self)
	
	tilemap.astar[z_index].set_point_solid(get_grid_position(), false)

func end_turn():
	if is_dead:
		return
	
	# Effect modifiers
	for i in effects.size():
		var j = effects.size() - 1 - i
		effects[j].on_end.call(self)
		if effects[j].turns_remaining <= 0:
			effects.remove_at(j)
	
	set_active(false)
	tilemap.astar[z_index].set_point_solid(get_grid_position())
