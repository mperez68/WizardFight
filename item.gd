enum ItemNames{ HEALTH_POTION, MANA_POTION, FIRE_BOMB }

class Item:

	var name
	var cost
	var quantity
	var damage
	var range
	var hit_chance
	var radius
	# todo add sprite/animation
	
	func _init(item: ItemNames):
		if item == ItemNames.HEALTH_POTION:
			populate("Health Potions", 0, 2, -2, 0)
		if item == ItemNames.MANA_POTION:
			populate("Mana Potions", -2, 2, 0, 0)
		if item == ItemNames.FIRE_BOMB:
			populate("Fire Bombs", 0, 3, 1, 5, 0.8, 1)
	
	func populate(new_name, new_cost, new_quantity, new_damage, new_range, new_hit_chance = 1, new_radius = 0):
		name = new_name
		cost = new_cost
		quantity = new_quantity
		damage = new_damage
		range = new_range
		hit_chance = new_hit_chance
		radius = new_radius
