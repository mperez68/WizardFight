const Effect = preload("res://status/StatusEffect.gd")

enum SpellNames{ MAGIC_MISSILE, FIRE_BLAST, SHOCKING_GRASP, HEALING_TOUCH, FIREBALL, TESTICULAR_TORSION }

class Spell:

	var name
	var spell_node
	var icon
	var cost
	var damage
	var range
	var hit_chance
	var crit_chance
	var self_cast
	var radius
	var status: Effect.StatusEffect
	var tooltip: String
	
	func _init(spell: SpellNames):
		tooltip = "this is a tooltip!"
		match spell:
			SpellNames.MAGIC_MISSILE:
				populate("Magic Missile", preload("res://spells/magic_missile.tscn"), preload("res://assets/spells/Wind/tile003.png"), 1, 1, 6, 1, 0)
				tooltip = "Always hits. Never impresses."
			SpellNames.FIRE_BLAST:
				populate("Fire Blast", preload("res://spells/fire_blast.tscn"), preload("res://assets/spells/Fire_Ball/tile000.png"), 2, 2, 8, 0.7, 0.1)
				tooltip = "Scholars often argue about where the flame comes from but I wouldn't be worried about that right now. Long range, decent damage."
			SpellNames.SHOCKING_GRASP:
				populate("Shocking Grasp", preload("res://spells/shocking_grasp.tscn"), preload("res://assets/spells/Tornado/tile009.png"), 3, 3, 1, 0.8, 0.3)
				tooltip = "Bzzt."
			SpellNames.HEALING_TOUCH:
				populate("Healing Touch", preload("res://spells/healing_touch.tscn"), preload("res://assets/spells/Water_Geyser/tile008.png"), 2, -2, 1, 1, 0.4, true)
				tooltip = "Unhurts the target, which is less exciting but [i]can[/i] be useful."
			SpellNames.FIREBALL:
				populate("Fireball", preload("res://spells/fireball.tscn"), preload("res://assets/spells/Explosion/tile005.png"), 3, 1, 8, 0.7, 0.1, 3)
				tooltip = "You had a personality until you put this spell in your tome. Go ahead, free-thinker."
			SpellNames.TESTICULAR_TORSION:
				populate("Testicular Torsion", preload("res://spells/testicular_torsion.tscn"), preload("res://assets/spells/Tornado/tile009.png"), 3, 1, 4, 0.8, 0.2, 0, false, Effect.EffectNames.SLOW)
				tooltip = "Jesus fucking Christ, you monster. Slows target for two turns."
			_:
				populate("Magic Missile", preload("res://spells/magic_missile.tscn"), preload("res://assets/spells/Wind/tile003.png"), 1, 1, 6, 1, 0)	#default to magic missile todo change to rock
	
	func populate(new_name, new_node, new_icon, new_cost, new_damage, new_range, new_hit_chance, new_crit_chance, new_radius = 0, new_self_cast = false, new_effect = null ):
		name = new_name
		spell_node = new_node
		icon = new_icon
		cost = new_cost
		damage = new_damage
		range = new_range
		hit_chance = new_hit_chance
		crit_chance = new_crit_chance
		self_cast = new_self_cast
		radius = new_radius
		if new_effect:
			status = Effect.StatusEffect.new(new_effect)
