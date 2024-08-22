enum ProfileNames{ MINION, SUPPORT, ORC }

class AiProfile:
	var _char: TacticsCharacter
	var level
	var tilemap
	var _adj_vectors
	var _profile: ProfileNames
	var priority = []
	var target: TacticsCharacter
	var ally: TacticsCharacter
	
	func _init(char: TacticsCharacter, profile: ProfileNames):
		_char = char
		level = char.level
		tilemap = char.tilemap
		_adj_vectors = char._adj_vectors
		_profile = profile
		
		match profile:
			ProfileNames.SUPPORT:
				priority.push_back(shoot_ally)
				priority.push_back(approach_ally)
				priority.push_back(shoot)
				priority.push_back(approach_enemy)
			ProfileNames.ORC:
				priority.push_back(approach_enemy)
				priority.push_back(shoot)
			_:
				priority.push_back(shoot)
				priority.push_back(approach_enemy)

	# Decision Making
	func find_closest_target(team: int, is_team = true):
		var best_target:TacticsCharacter = null
		var best_distance = 999
		var temp_distance = best_distance
		var temp_manhattan = temp_distance
		
		for i in level.characters.size():
			# Only proceed if they're the correct team we're looking for and not dead or self
			if is_team == (level.characters[i].team == team) and !level.characters[i].is_dead and self != level.characters[i]:
				temp_manhattan = tilemap.distance_to(level.characters[i].z_index, level.characters[i].global_position, _char.z_index, _char.global_position)
				# Adjacent, break and assume this is best
				if temp_manhattan == 1:
					return level.characters[i]
				for j in _adj_vectors.size():
					temp_distance = tilemap.distance_to_weighted(_char.z_index, level.characters[i].global_position + _adj_vectors[j], _char.global_position)
					if temp_manhattan > 0 and temp_distance > 0 and temp_distance < best_distance:
						best_distance = temp_distance
						best_target = level.characters[i]
		return best_target
	
	func set_spell_to_enemy():
		# set spell pointer to damaging spell
		for i in _char.spells.size():
			if _char.spells[i].damage > 0:
				_char.spell_pointer = i
				break
	
	func set_spell_to_ally():
		# set spell pointer to friendly spell
		for i in _char.spells.size():
			if _char.spells[i].damage <= 0:
				_char.spell_pointer = i
				break
	
	var approach_enemy = func():
		set_spell_to_enemy()
		# break if not able to approach
		if !(target and _char.speed > 0 and !tilemap.is_visible_target(target.z_index, target.global_position, _char.z_index, _char.global_position, _char.spells[_char.spell_pointer].range)):
			return false
		
		var best_loc
		var best_distance = 999
		var temp_distance = best_distance
		
		for i in _adj_vectors.size():
			temp_distance = tilemap.distance_to_weighted(_char.z_index, target.global_position + _adj_vectors[i], _char.global_position)
			if temp_distance != 0 and temp_distance < best_distance:
				best_distance = temp_distance
				best_loc = target.global_position + _adj_vectors[i]
		
		var grid_loc = tilemap.local_to_map(_char.global_position)
		_char.current_path = tilemap.astar[_char.z_index].get_id_path(grid_loc, tilemap.local_to_map(best_loc)).slice(1)
		var move = min(_char.speed, _char.current_path.size())
		_char.current_path = _char.current_path.slice(0, move)
		_char.speed -= move
		
		# Set camera focus
		if _char.current_path.size() > 0:
			_char.focus = (tilemap.map_to_local(_char.current_path.back()) + _char.global_position) / 2
		
		return true
	
	var approach_ally = func():
		if ally and (ally.hp == ally._max_hp or ally.is_dead):
			return false
		
		set_spell_to_ally()
		# break if not able to approach
		if !(ally and _char.speed > 0 and tilemap.distance_to(ally.z_index, ally.global_position, _char.z_index, _char.global_position) > _char.spells[_char.spell_pointer].range):
			return false
		
		var best_loc
		var best_distance = 999
		var temp_distance = best_distance
		
		for i in _adj_vectors.size():
			temp_distance = tilemap.distance_to_weighted(_char.z_index, ally.global_position + _adj_vectors[i], _char.global_position)
			if temp_distance != 0 and temp_distance < best_distance:
				best_distance = temp_distance
				best_loc = ally.global_position + _adj_vectors[i]
		
		var grid_loc = tilemap.local_to_map(_char.global_position)
		_char.current_path = tilemap.astar[_char.z_index].get_id_path(grid_loc, tilemap.local_to_map(best_loc)).slice(1)
		var move = min(_char.speed, _char.current_path.size())
		_char.current_path = _char.current_path.slice(0, move)
		_char.speed -= move
		
		# Set camera focus
		if _char.current_path.size() > 0:
			_char.focus = (tilemap.map_to_local(_char.current_path.back()) + _char.global_position) / 2
		
		return true
	
	var shoot = func():		#todo add radius optimization i.e. shoot at location that maximizes targets
		set_spell_to_enemy()
		var valid_spell = false
		for i in _char.spells.size():
			if target and _char.can_cast(i) and tilemap.is_visible_target(target.z_index, target.global_position, _char.z_index, _char.global_position, _char.spells[i].range):
				_char.spell_pointer = i
				valid_spell = true
				break
		if !valid_spell:
			return false
		
		if target and _char.attacks > 0 and _char.mana >= _char.spells[_char.spell_pointer].cost and tilemap.distance_to(target.z_index, target.global_position, _char.z_index, _char.global_position) <= _char.spells[_char.spell_pointer].range:
			_char.shoot(_char.spells[_char.spell_pointer], target.get_grid_position(), target.z_index)
			return true
		else:
			return false
	
	var shoot_ally = func():
		if ally and (ally.hp == ally._max_hp or ally.is_dead):
			return false
		
		set_spell_to_ally()
		if ally and _char.attacks > 0 and _char.mana >= _char.spells[_char.spell_pointer].cost and tilemap.distance_to(ally.z_index, ally.global_position, _char.z_index, _char.global_position) <= _char.spells[_char.spell_pointer].range:
			_char.shoot(_char.spells[_char.spell_pointer], ally.get_grid_position(), ally.z_index)
			return true
		else:
			return false
	
	func turn_process():
		var took_action = false
		# Find targets
		target = find_closest_target(_char.team, false)
		ally = find_closest_target(_char.team)
		
		for i in priority.size():
			took_action = priority[i].call()
			if took_action:
				break
		
		# spin lock until finished
		var wait_time = 1
		if (level.characters.size() > 5):
			wait_time = 0.8
		if (level.characters.size() > 10):
			wait_time = 0.5
		if (level.characters.size() > 15):
			wait_time = 0
		while !_char.current_path.is_empty() or _char.active_missiles > 0:
			await _char.get_tree().create_timer(wait_time).timeout
			# if scene changes, this timeout thread will continue and try to call freed resources.
			if not is_instance_valid(_char):	
				return
		
		# if no actions possible, end turn
		if took_action:
			turn_process()
		else:
			level.inc_turn()
