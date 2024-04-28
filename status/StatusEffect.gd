enum EffectNames{ POISON, SLOW, RUSH, SPELLSHIELD, STUN }

var _adj_vectors: Array[Vector2]

class StatusEffect:

	var name
	var enum_key: EffectNames
	var turns_start
	var turns_remaining
	var effect_node
	var on_start
	var on_end
	
	# To add new effects:
	#	- add name to EffectNames
	#	- add match case in _init()
	#	- add match case in on_start() to corresponding effect
	#	- add match case in on_end() to corresponding effect
	#	- add function for the effect
	func _init(effect: EffectNames, turns:int = 0):
		enum_key = effect
		match effect:
			EffectNames.POISON:
				populate("Poison", 2, null, poison, _on_end)
			EffectNames.SLOW:
				populate("Slow", 1, null, slow, _on_end)
			EffectNames.RUSH:
				populate("Rush", 1, null, rush, _on_end)
			EffectNames.SPELLSHIELD:
				populate("Spellshield", 2, null, fall_off, _on_end)
			EffectNames.STUN:
				populate("Stun", 1, null, stun, _on_end)
			_:
				pass
		if turns:
			turns_start = turns
	
	func populate(new_name, new_turns_start, new_effect_node, new_on_start, new_on_end):
		name = new_name
		turns_start = new_turns_start
		turns_remaining = turns_start
		on_start = new_on_start
		on_end = new_on_end
		effect_node = null
	
	var _on_end = func(target: TacticsCharacter):
		turns_remaining -= 1
	
	# Effect functions
	var none = func(target: TacticsCharacter):
		pass
	
	var stun = func(target: TacticsCharacter):
		target.speed = 0
		target.attacks = 0
		target.item_uses = 0
	
	var fall_off = func(target: TacticsCharacter):
		turns_remaining = 0
	
	var poison = func(target: TacticsCharacter):
		target.add_hp(-(randi() % 2) - 1)

	var slow = func(target: TacticsCharacter):
		target.speed -= 2
		
	var rush = func(target: TacticsCharacter):
		target.speed += 2
	
