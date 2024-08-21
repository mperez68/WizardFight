const Effect = preload("res://status/StatusEffect.gd")

enum SpellNames{ MAGIC_MISSILE, FIRE_BLAST, HEALING_TOUCH, TELEPORT, FIREBALL, COUNTERSPELL, SHOCKING_GRASP, 
TESTICULAR_TORSION, SWAP, MM_BARRAGE, LIGHTNING_BOLT, RAISE_DEAD, ESPRESSO, SHART, SPEAR, ROCK }

class Spell:

	var name
	var spell_node
	var icon
	var cost
	var damage
	var range
	var hit_chance
	var crit_chance
	var self_cast = false
	var radius = 0
	var no_target = false
	var is_line = false
	var status: Effect.StatusEffect = null
	var tooltip: String = "this is a tooltip!"
	
	func _init(spell: SpellNames = -1):
		_populate(spell)
	
	func _populate(spell: SpellNames = -1):
		match spell:
			SpellNames.MAGIC_MISSILE:
				populate("Magic Missile", preload("res://spells/magic_missile.tscn"), preload("res://assets/spells/Wind/tile003.png"), 1, 1, 6)
				tooltip = "Always hits. Never impresses."
			SpellNames.FIRE_BLAST:
				populate("Fire Blast", preload("res://spells/fire_blast.tscn"), preload("res://assets/spells/Fire_Ball/tile000.png"), 2, 2, 8, 0.7, 0.1)
				tooltip = "Scholars often argue about where the flame comes from but I wouldn't be worried about that right now. Long range, decent damage."
			SpellNames.SHOCKING_GRASP:
				populate("Shocking Grasp", preload("res://spells/shocking_grasp.tscn"), preload("res://assets/spells/Shocking_Grasp/tile.png"), 3, 3, 1, 0.8, 0.3)
				tooltip = "Bzzt."
			SpellNames.HEALING_TOUCH:
				populate("Healing Touch", preload("res://spells/healing_touch.tscn"), preload("res://assets/spells/Water_Geyser/tile008.png"), 2, -2, 1, 1, 0.4)
				self_cast = true
				tooltip = "Unhurts the target, which is less exciting but [i]can[/i] be useful."
			SpellNames.FIREBALL:
				populate("Fireball", preload("res://spells/fireball.tscn"), preload("res://assets/spells/Explosion/tile005.png"), 3, 1, 8, 0.7, 0.1)
				radius = 2
				tooltip = "You had a personality until you put this spell in your tome. Go ahead, free-thinker."
			SpellNames.TESTICULAR_TORSION:
				populate("Testicular Torsion", preload("res://spells/testicular_torsion.tscn"), preload("res://assets/spells/Torsion/tile.png"), 3, 1, 4, 0.8, 0.2)
				status = Effect.StatusEffect.new(Effect.EffectNames.SLOW)
				tooltip = "Jesus fucking Christ, you monster. Slows target for two turns."
			SpellNames.COUNTERSPELL:
				populate("Spellshield", preload("res://spells/spellshield.tscn"), preload("res://assets/spells/Counterspell/tile.png"), 1)
				tooltip = "Just say no to malicious sorcery."
				self_cast = true
				status = Effect.StatusEffect.new(Effect.EffectNames.SPELLSHIELD)
			SpellNames.TELEPORT:
				populate("Teleport", preload("res://spells/teleport.tscn"), preload("res://assets/spells/Teleport/tile004.png"), 0, 0, 5)
				tooltip = "For when you need to be over there instead of over here."
				no_target = true
			SpellNames.SWAP:
				populate("Swaparoo", preload("res://spells/swap.tscn"), preload("res://assets/spells/Swap/tile004.png"), 2, 0, 4)
				tooltip = "This spell puts here there and there here."
			SpellNames.MM_BARRAGE:
				populate("Magic Missile Barrage", preload("res://spells/magic_missile.tscn"), preload("res://assets/spells/Magic_Missile_Barrage/tile003.png"), 3, 1, 5)
				radius = 1
				is_line = true
				tooltip = "Always hits, almost impresses."
			SpellNames.LIGHTNING_BOLT:
				populate("Lightning Bolt", preload("res://spells/lightning_bolt.tscn"), preload("res://assets/spells/Lightning_Bolt/tile.png"), 3, 2, 8, 0.8, 0.3)
				is_line = true
				tooltip = "BZZT. Strikes targets in a line to share the fun."
			SpellNames.RAISE_DEAD:
				populate("Raise Dead", preload("res://spells/raise_dead.tscn"), preload("res://assets/spells/Raise_Dead/tile.png"), 3, 0, 3)
				no_target = true
				tooltip = "Well he's not using it anymore. Raises target as a much worse version of themselves."
			SpellNames.ESPRESSO:
				populate("Espresso Expresso", preload("res://spells/espresso.tscn"), preload("res://assets/spells/Expresso_Expresso/tile.png"), 0)
				tooltip = "Cranks up the heartrate. Increases move speed by 2 for 3 turns."
				self_cast = true
				status = Effect.StatusEffect.new(Effect.EffectNames.RUSH)
			SpellNames.SHART:
				populate("Power Word: Shart", preload("res://spells/shart.tscn"), preload("res://assets/spells/Power_Word_Shart/tile.png"), 3, 0, 4, 0.7)
				status = Effect.StatusEffect.new(Effect.EffectNames.STUN)
				tooltip = "Forces the target to take a long second to make sure nobody noticed (skips their next turn)."
			SpellNames.ROCK:
				populate("Rock", preload("res://spells/rock.tscn"), preload("res://assets/spells/Rocks/tile007.png"), 0, 1, 4, 0.5)
				tooltip = "A simpler spell for a simpler time."
			SpellNames.SPEAR:
				populate("Spear", preload("res://spells/axe.tscn"), preload("res://assets/spells/Molten_Spear/tile006.png"), 0, 2, 1, 0.8, 0.4)
				tooltip = "Counterspell this, nerd."
			_:
				_populate(randi() % SpellNames.size())
				name = "Random Spell"
	
	func populate(new_name, new_node, new_icon, new_cost = 0, new_damage = 0, new_range = 0, new_hit_chance = 1, new_crit_chance = 0):
		name = new_name
		spell_node = new_node
		icon = new_icon
		cost = new_cost
		damage = new_damage
		range = new_range
		hit_chance = new_hit_chance
		crit_chance = new_crit_chance
