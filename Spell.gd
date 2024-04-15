const Effect = preload("res://StatusEffect.gd")

enum SpellNames{ MAGIC_MISSILE, FIRE_BLAST, SHOCKING_GRASP, HEALING_TOUCH, FIREBALL, TESTICULAR_TORSION }

class Spell:

	var name
	var cost
	var damage
	var range
	var hit_chance
	var crit_chance
	var radius
	var spell_node
	var status: Effect.StatusEffect
	
	func _init(spell: SpellNames):
		match spell:
			SpellNames.MAGIC_MISSILE:
				populate("Magic Missile", preload("res://magic_missile.tscn"), 1, 1, 6, 1, 0)
			SpellNames.FIRE_BLAST:
				populate("Fire Blast", preload("res://fire_blast.tscn"), 2, 2, 8, 0.7, 0.05)
			SpellNames.SHOCKING_GRASP:
				populate("Shocking Grasp", preload("res://shocking_grasp.tscn"), 3, 3, 1, 0.8, 0.1)
			SpellNames.HEALING_TOUCH:
				populate("Healing Touch", preload("res://healing_touch.tscn"), 2, -2, 1, 1, 0.3)
			SpellNames.FIREBALL:
				populate("Fireball", preload("res://fireball.tscn"), 3, 1, 8, 0.9, 0, 3)
			SpellNames.TESTICULAR_TORSION:
				populate("Testicular Torsion", preload("res://testicular_torsion.tscn"), 3, 1, 6, 1, 0, 0, Effect.EffectNames.SLOW)
			_:
				populate("Magic Missile", preload("res://magic_missile.tscn"), 1, 1, 6, 1, 0)	#default to magic missile todo change to rock
	
	func populate(new_name, new_node, new_cost, new_damage, new_range, new_hit_chance, new_crit_chance, new_radius = 0, new_effect = null ):
		name = new_name
		spell_node = new_node
		cost = new_cost
		damage = new_damage
		range = new_range
		hit_chance = new_hit_chance
		crit_chance = new_crit_chance
		radius = new_radius
		if new_effect:
			status = Effect.StatusEffect.new(new_effect)
