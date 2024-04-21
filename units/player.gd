extends TacticsCharacter

enum Select{ NONE, MOVE, SHOOT, ITEM }

var select_mode = Select.NONE

# Instantiate with Player specific variables
func _ready():
	_max_speed = 4
	_max_attacks = 1
	_max_item_uses = 1
	
	_max_hp = 5
	_max_mana = 3
	
	_hp_regen = 0
	_mana_regen = 1
	
	spells.push_back(Spell.Spell.new(Spell.SpellNames.TESTICULAR_TORSION))
	spells.push_back(Spell.Spell.new(Spell.SpellNames.FIRE_BLAST))
	#spells.push_back(Spell.Spell.new((randi() % 4) + 2))
	
	
	items.push_back(Item.Item.new(Item.ItemNames.HEALTH_POTION))
	items.push_back(Item.Item.new(Item.ItemNames.MANA_POTION))
	items.push_back(Item.Item.new(Item.ItemNames.FIRE_BOMB))
	items.push_back(Item.Item.new(Item.ItemNames.SCROLL, Spell.SpellNames.HEALING_TOUCH))
	items.push_back(Item.Item.new(Item.ItemNames.SCROLL, Spell.SpellNames.FIREBALL))
	
	super()
	
	team = 0

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
	elif select_mode == Select.ITEM and tilemap.is_visible_target(z_index, get_global_mouse_position(), z_index, global_position, items[item_pointer].range):
		tilemap.draw_target(z_index, get_global_mouse_position(), items[item_pointer].radius, true)
	elif (select_mode == Select.SHOOT or select_mode == Select.ITEM):
		tilemap.clear_target()

func _on_hit():
	super()
	if active_missiles <= 0:
		reset_hud()

func reset_hud():
	level.set_hud(true)
	if speed <= 0:
		level.set_hud(false, "Move")
	if attacks <= 0:
		level.set_hud(false, "Spell")
	if item_uses <= 0:
		level.set_hud(false, "Item")

# IO Events
func _unhandled_input(event):
	# Break if clicking at the wrong time
	if !current_path.size() == 0 or !is_active:
		return
	
	# Break current selection
	if event.is_action_pressed("ui_cancel") and select_mode != Select.NONE:
		select_mode = Select.NONE
		set_highlight()
		tilemap.clear_target()
	
	# Collect position
	var click_position = get_global_mouse_position()
	
	# Select shooting target if possible
	if event.is_action_pressed("primary_mouse") and select_mode == Select.SHOOT:
		select_shoot(click_position)
		
	# Select item target if possible
	if event.is_action_pressed("primary_mouse") and select_mode == Select.ITEM:
		select_item(click_position)
	
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
		Select.ITEM:
			tilemap.draw_range(z_index, global_position, items[item_pointer].range, true)
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
	
	# Self-cast
	if items[item_pointer].range == 0:
		use_item()
	else:
		select_mode = Select.ITEM

# targetting via mouse clicks
func select_shoot(click_position):
	var grid_loc = tilemap.local_to_map(global_position)
	var target_grid_loc = tilemap.local_to_map(click_position)
	
	if attacks <= 0:
		return
	
	if ((grid_loc == target_grid_loc and spells[spell_pointer].self_cast) or tilemap.is_visible_target(z_index, click_position, z_index, global_position, spells[spell_pointer].range)) and select_mode == Select.SHOOT:
		select_mode = Select.NONE
		set_highlight(false)
		level.set_hud(false)
		tilemap.clear_target()
		
		# damage any targets at location
		shoot(spells[spell_pointer], target_grid_loc, z_index)
		
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
			level.camera.position = focus
			level.set_hud(false)

func select_item(click_position):
	var grid_loc = tilemap.local_to_map(global_position)
	var target_grid_loc = tilemap.local_to_map(click_position)
	
	if item_uses <= 0 or items[item_pointer].cost > mana:
		return
	
	# Spell-Like
	if !items[item_pointer].spell and (tilemap.is_visible_target(z_index, click_position, z_index, global_position, items[item_pointer].range)) and select_mode == Select.ITEM:
		select_mode = Select.NONE
		set_highlight(false)
		level.set_hud(false)
		tilemap.clear_target()
		
		# damage any targets at location
		use_item(item_pointer, target_grid_loc, z_index)
	
	
	# Scrolls
	if items[item_pointer].spell and ((grid_loc == target_grid_loc and items[item_pointer].spell.self_cast) or tilemap.is_visible_target(z_index, click_position, z_index, global_position, items[item_pointer].spell.range)) and select_mode == Select.ITEM:
		select_mode = Select.NONE
		set_highlight(false)
		level.set_hud(false)
		tilemap.clear_target()
		
		# damage any targets at location
		use_item(item_pointer, target_grid_loc, z_index)
		
		# reset highlights
		tilemap.draw_weighted_range(z_index, global_position, speed, false)

func use_item(pointer = item_pointer, location = get_grid_position(), layer = z_index):
	super(pointer, location, layer)
	reset_hud()

func start_turn():
	super()
	reset_hud()
