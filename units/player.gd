extends TacticsCharacter

enum Select{ NONE, MOVE, SHOOT, ITEM }

var select_mode = Select.NONE

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
	spells.push_back(Spell.Spell.new(Spell.SpellNames.FIREBALL))
	spells.push_back(Spell.Spell.new(Spell.SpellNames.TESTICULAR_TORSION))
	
	items.push_back(Item.Item.new(Item.ItemNames.HEALTH_POTION))
	items.push_back(Item.Item.new(Item.ItemNames.MANA_POTION))
	
	super()

# Viewport Updates
func _physics_process(_delta):
	var path_size = current_path.size()
	
	super(_delta)
	
	# update path when location is reached
	if path_size and current_path.is_empty() and is_active:
		set_highlight()
		reset_hud()

func _process(delta):
	if select_mode == Select.SHOOT and tilemap.is_visible_target(z_index, get_global_mouse_position(), z_index, global_position, spells[spell_pointer].range):
		tilemap.draw_target(z_index, get_global_mouse_position(), spells[spell_pointer].radius, true)
	elif select_mode == Select.SHOOT:
		tilemap.clear_target()

func _on_hit():
	super()
	if active_missiles == 0:
		reset_hud()

func reset_hud():
	main.set_hud(true)
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
	if event.is_action_pressed("ui_cancel") and select_mode != Select.NONE:
		select_mode = Select.NONE
		set_highlight()
	
	# Collect position
	var click_position = get_global_mouse_position()
	
	# Select shooting target if possible
	if event.is_action_pressed("primary_mouse") and select_mode == Select.SHOOT:
		select_shoot(click_position)
	
	# Select moving target if possible
	if event.is_action_pressed("primary_mouse") and tilemap.is_point_walkable(z_index, click_position):
		select_move(click_position)

# Overrides
func set_active(new_state = true):
	super(new_state)
	select_mode = Select.NONE
	set_highlight(new_state)

func set_highlight(active = true):
	if !active:
		tilemap.clear_highlights()
		return
	match select_mode:
		Select.MOVE:
			tilemap.draw_weighted_range(z_index, global_position, speed, true)
		Select.SHOOT:
			tilemap.draw_range(z_index, global_position, spells[spell_pointer].range, true)
		Select.NONE:
			tilemap.draw_weighted_range(z_index, global_position, speed, false)
		_:
			tilemap.clear_highlights()

# HUD interactions
func button_shoot(selected_spell: int):
	if attacks <= 0 or !current_path.size() == 0:
		return
	
	if selected_spell < spells.size():
		spell_pointer = selected_spell
	else:
		return
	
	select_mode = Select.SHOOT
	set_highlight()

func button_move():
	if speed <= 0 and !current_path.size() == 0:
		return
	
	select_mode = Select.MOVE
	set_highlight()

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
	
	if ((grid_loc == target_grid_loc and spells[spell_pointer].self_cast) or tilemap.is_visible_target(z_index, click_position, z_index, global_position, spells[spell_pointer].range)) and select_mode == Select.SHOOT:
		select_mode = Select.NONE
		set_highlight(false)
		main.set_hud(false)
		tilemap.clear_target()
		
		# damage any targets at location
		if spells[spell_pointer].radius:
			shoot_radius(target_grid_loc, z_index)
		else:
			for i in main.characters.size():
				if main.characters[i].get_grid_position() == target_grid_loc:
					shoot(main.characters[i])
					break
		
		# reset highlights
		tilemap.draw_weighted_range(z_index, global_position, speed, false)

func select_move(click_position):
	var grid_loc = tilemap.local_to_map(global_position)
	var target_grid_loc = tilemap.local_to_map(click_position)
	
	var temp_path = tilemap.astar[z_index].get_id_path(grid_loc, target_grid_loc).slice(1)
	
	if tilemap.distance_to_weighted(z_index, click_position, global_position) <= speed and select_mode == Select.MOVE:
		current_path = temp_path
		select_mode = Select.NONE
		tilemap.clear_highlights()
		
		vert_check(current_path)
		
		# Set camera focus
		if current_path.size() > 0:
			focus = (tilemap.map_to_local(current_path.back()) + global_position) / 2
			main.camera.position = focus
			main.set_hud(false)

func use_item(pointer = item_pointer, target: CharacterBody2D = null):
	super()
	reset_hud()

func start_turn():
	super()
	reset_hud()
