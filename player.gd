extends TacticsCharacter

var is_selecting_move = false
var is_selecting_shoot = false

# Instantiate with Player specific variables
func _ready():
	MAX_SPEED = 4
	MAX_ATTACKS = 1
	MAX_ITEM_USES = 1
	
	MAX_HP = 5
	MAX_MANA = 3
	
	HP_REGEN = 0
	MANA_REGEN = 1
	
	spells.push_back(Spell.Spell.new(Spell.SpellNames.FIRE_BLAST))
	spells.push_back(Spell.Spell.new(Spell.SpellNames.SHOCKING_GRASP))
	spells.push_back(Spell.Spell.new(Spell.SpellNames.HEALING_TOUCH))
	spells.push_back(Spell.Spell.new(Spell.SpellNames.FIREBALL))
	
	items.push_back(Item.Item.new(Item.ItemNames.HEALTH_POTION))
	items.push_back(Item.Item.new(Item.ItemNames.MANA_POTION))
	
	super()

# Viewport Updates
func _physics_process(_delta):
	super(_delta)
	
	# update path when location is reached
	if current_path.is_empty() and is_active:
		main.set_hud(true)
		if !is_selecting_move and !is_selecting_shoot:
			tilemap.draw_weighted_range(z_index, global_position, speed, is_selecting_move)
		if speed <= 0:
			main.set_hud(false, "Move")
		if attacks <= 0:
			main.set_hud(false, "Spell")
		if item_uses <= 0:
			main.set_hud(false, "Item")

# IO Events
func _unhandled_input(event):
	# Break if clicking at the wrong time
	if !current_path.size() == 0 or !is_active:
		return
	
	# Break current selection
	if event.is_action_pressed("ui_cancel") and (is_selecting_move or is_selecting_shoot):
		is_selecting_move = false
		is_selecting_shoot = false
		tilemap.draw_weighted_range(z_index, global_position, speed, is_selecting_move)
	
	# Collect position
	var click_position = get_global_mouse_position()
	
	# Select shooting target if possible
	if (event.is_action_pressed("alternate_mouse") and !is_selecting_shoot and can_cast()) or (event.is_action_pressed("primary_mouse") and is_selecting_shoot):
		select_shoot(click_position)
	
	# Select moving target if possible
	if event.is_action_pressed("primary_mouse") and tilemap.is_point_walkable(z_index, click_position):
		select_move(click_position)

# Overrides
func set_active(new_state = true):
	super(new_state)
	is_selecting_move = false
	is_selecting_shoot = false
	if new_state:
		tilemap.draw_weighted_range(z_index, global_position, speed, is_selecting_move)
	else:
		tilemap.clear_highlights()

# HUD interactions
func button_shoot(selected_spell: int):
	if attacks <= 0 or !current_path.size() == 0:
		return
	
	if selected_spell < spells.size():
		spell_pointer = selected_spell
	else:
		return
	
	is_selecting_shoot = true
	is_selecting_move = false
	tilemap.draw_range(z_index, global_position, spells[spell_pointer].range, is_selecting_shoot)

func button_move():
	if speed <= 0 and !current_path.size() == 0:
		return
	
	is_selecting_move = true
	is_selecting_shoot = false
	tilemap.draw_weighted_range(z_index, global_position, speed, is_selecting_move)

func button_item(selected_item: int):
	if item_uses <= 0 or !current_path.size() == 0:
		return
	
	if selected_item < items.size():
		item_pointer = selected_item
	else:
		return
	
	use_item()

# targetting via mouse clicks
func select_shoot(click_position):
	var grid_loc = tilemap.local_to_map(global_position)
	var target_grid_loc = tilemap.local_to_map(click_position)
	
	if attacks <= 0:
		return
	
	if tilemap.is_visible_target(z_index, click_position, z_index, global_position, spells[spell_pointer].range) and is_selecting_shoot:
		is_selecting_move = false
		is_selecting_shoot = false
		
		tilemap.clear_highlights()
		main.set_hud(false)
		
		# damage any targets at location
		if spells[spell_pointer].radius:
			shoot_radius(target_grid_loc, z_index)
		else:
			for i in main.characters.size():
				if main.characters[i].get_grid_position() == target_grid_loc:
					shoot(main.characters[i])
					break
		
		# reset highlights
		tilemap.draw_weighted_range(z_index, global_position, speed, is_selecting_move)
	
	if grid_loc == target_grid_loc:
		is_selecting_shoot = !is_selecting_shoot
		is_selecting_move = false
		tilemap.draw_range(z_index, global_position, spells[spell_pointer].range, is_selecting_shoot)

func select_move(click_position):
	var grid_loc = tilemap.local_to_map(global_position)
	var target_grid_loc = tilemap.local_to_map(click_position)
	
	var temp_path = tilemap.astar[z_index].get_id_path(grid_loc, target_grid_loc).slice(1)
	
	if tilemap.distance_to_weighted(z_index, click_position, global_position) <= speed and is_selecting_move:
		current_path = temp_path
		is_selecting_move = false
		is_selecting_shoot = false
		tilemap.clear_highlights()
		
		vert_check(current_path)
		
		# Set camera focus
		if current_path.size() > 0:
			focus = (tilemap.map_to_local(current_path.back()) + global_position) / 2
			main.set_hud(false)
		
	if grid_loc == target_grid_loc:
		is_selecting_move = !is_selecting_move
		is_selecting_shoot = false
		tilemap.draw_weighted_range(z_index, global_position, speed, is_selecting_move)
