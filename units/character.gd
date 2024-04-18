extends CharacterBody2D

class_name TacticsCharacter

const ANIM_SPEED = 4
const Spell = preload("res://spells/Spell.gd")
const Item = preload("res://items/item.gd")
const Effect = preload("res://status/StatusEffect.gd")
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
		if current_path.is_empty():
			# Set camera focus
			focus = global_position
			main.camera.position = focus
		
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

func can_cast(pointer = null, spell: Spell.Spell = null):
	var temp_pointer = spell_pointer
	if !pointer:
		for i in spells.size():
			if spells[i].cost <= mana:
				spell_pointer = i
				break
	var temp_spell
	if spell:
		temp_spell = spell
	else:
		temp_spell = spells[temp_pointer]
	return attacks > 0 and mana >= temp_spell.cost

func get_radius(radius: int, origin: Vector2i = get_grid_position(), layer: int = z_index):
	
	var targets: Array[TacticsCharacter] = []
	var rough_range_start = origin - Vector2i(radius, radius)
	for i in 2 * radius + 1:
		for j in 2 * radius + 1:
			var temp_loc = Vector2i(i, j) + rough_range_start
			# select any targets at location
			for k in main.characters.size():
				if main.characters[k].get_grid_position() == temp_loc:
					targets.push_back(main.characters[k])
	
	return targets

func _on_hit():
	active_missiles -= 1
	if active_missiles <= 0:
		focus = global_position
		main.camera.position = focus
	
func shoot(spell: Spell.Spell, location: Vector2i, layer = z_index):
	if !can_cast(spell):
		print("Cannot cast! ", mana, " < ", spell.cost, " :: attacks == ", attacks)
		return false
	
	var targets = get_radius(spell.radius, location, layer)
	
	if targets.size():
		anim.play("cast")
		add_mana(-spell.cost)
		attacks -= 1
	else:
		_on_hit()
		return false
	
	active_missiles = 0
	for i in targets.size():
		var missile = spell.spell_node.instantiate()
		missile.start(targets[i], global_position)
		active_missiles += 1
		missile.hit.connect(_on_hit)
		add_child(missile)
	
	focus_targets(targets)
	return true

func focus_targets(targets):
	# change focus
	var focus_targets = targets
	focus_targets.push_front(self)
	var temp = Vector2()
	for i in focus_targets.size():
		temp += focus_targets[i].position
	focus = temp / focus_targets.size()
	main.camera.position = focus

func use_item(pointer = item_pointer, location = get_grid_position(), layer = z_index):
	var targets: Array[TacticsCharacter] = []
	if !items[pointer].range:
		targets.push_front(self)
	else:
		targets = get_radius(items[pointer].radius, location, layer)
	
	if targets.is_empty():
		return
	
	if items[pointer].spell:
		if shoot(items[pointer].spell, location, layer):
			# refund resources
			add_mana(items[item_pointer].spell.cost - items[item_pointer].cost)
			attacks += 1
	else:
		active_missiles = 0
		for i in targets.size():
			var missile = items[pointer].item_node.instantiate()
			missile.start(targets[i], global_position)
			active_missiles += 1
			missile.hit.connect(_on_hit)
			add_child(missile)
			
		focus_targets(targets)
	
	# Expend item
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
	
	focus = global_position
	main.camera.position = focus
	main.camera.zoom = Vector2(1, 1)
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
	
	main.camera.position = focus
	# Effect modifiers
	for i in effects.size():
		var j = effects.size() - 1 - i
		effects[j].on_end.call(self)
		if effects[j].turns_remaining <= 0:
			effects.remove_at(j)
	
	set_active(false)
	tilemap.astar[z_index].set_point_solid(get_grid_position())
