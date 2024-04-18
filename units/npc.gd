extends TacticsCharacter

class_name NPC

var tooltip_text = "This is tooltip text!"
var tooltip_name = "NPC"

func find_target():
	print("find_target():", name)
	var best_target
	var best_distance = 999
	var temp_distance = best_distance
	
	for i in main.characters.size():
		for j in ADJ_VECTORS.size():
			temp_distance = tilemap.distance_to_weighted(z_index, main.characters[i].global_position + ADJ_VECTORS[j], global_position)
			if main.characters[i].name.contains("Player") and temp_distance != 0 and temp_distance < best_distance:
				best_distance = temp_distance
				best_target = main.characters[i]
				
	return best_target

func approach(target: CharacterBody2D):
	print("approach():", name)
	var best_loc
	var best_distance = 999
	var temp_distance = best_distance
	
	for i in ADJ_VECTORS.size():
		temp_distance = tilemap.distance_to_weighted(z_index, target.global_position + ADJ_VECTORS[i], global_position)
		if temp_distance != 0 and temp_distance < best_distance:
			best_distance = temp_distance
			best_loc = target.global_position + ADJ_VECTORS[i]
	
	var grid_loc = tilemap.local_to_map(global_position)
	current_path = tilemap.astar[z_index].get_id_path(grid_loc, tilemap.local_to_map(best_loc)).slice(1)
	var move = min(speed, current_path.size())
	current_path = current_path.slice(0, move)
	speed -= move
	
	# Set camera focus
	if current_path.size() > 0:
		focus = (tilemap.map_to_local(current_path.back()) + global_position) / 2

func evade(_target: CharacterBody2D):
	speed = 0
	#todo body

func turn_process():
	var target = find_target()
	
	# Move closer if not in range
	if target and speed > 0 and tilemap.distance_to(target.z_index, target.global_position, z_index, global_position) > spells[spell_pointer].range:
		approach(target)
	
	# spin lock until finished moving
	while !current_path.is_empty():
		await get_tree().create_timer(2).timeout
	
	# Shoot if in range
	if target and attacks > 0 and mana >= spells[spell_pointer].cost and tilemap.distance_to(target.z_index, target.global_position, z_index, global_position) <= spells[spell_pointer].range:
		shoot(spells[spell_pointer], target.get_grid_position(), target.z_index)
	
	while active_missiles > 0:
		await get_tree().create_timer(2).timeout
	
	# Move away if no attacks
	#if target and speed > 0:
		#evade(target)
	
	# if no actions possible, end turn
	main.inc_turn()

func start_turn():
	super()
	
	if is_dead:
		main.inc_turn()
		return
	
	await get_tree().create_timer(1).timeout
	turn_process()

# Tooltip fill/clear
func populate_tooltip():
	var icons = main.get_tooltip_icons("Spell")
	# set [in]visible and name buttons
	for i in icons.size():
		if i < spells.size():
			icons[i].visible = true
			icons[i].texture = spells[i].icon
		else:
			icons[i].visible = false

func clear_tooltip():
	var icons = main.get_tooltip_icons("Spell")
	for i in icons.size():
		icons[i].visible = false

func _on_mouse_entered():
	populate_tooltip()
	main.tooltip.clear()
	main.tooltip.append_text("[b]%s[/b]\n" % [tooltip_name])
	main.tooltip.append_text(tooltip_text)
	if main.characters[main.turn_pointer].name.contains("Player"):
		tilemap.draw_weighted_range(z_index, global_position, MAX_SPEED, true)

func _on_mouse_exited():
	clear_tooltip()
	main.tooltip.clear()
	if main.characters[main.turn_pointer].name.contains("Player"):
		main.characters[main.turn_pointer].set_highlight()
