const Spell = preload("res://spells/Spell.gd")

enum ItemNames{ HEALTH_POTION, MANA_POTION, FIRE_BOMB, SCROLL }

class Item:

	var name
	var item_node
	var status
	var icon
	var cost
	var quantity
	var damage
	var range
	var hit_chance
	var crit_chance = 0
	var radius
	var tooltip
	var spell: Spell.Spell
	
	func _init(item: ItemNames, spell_in: Spell.SpellNames = -1):
		icon = preload("res://assets/item.png")
		tooltip = "this is an item tooltip!"
		spell = null
		
		match item:
			ItemNames.HEALTH_POTION:
				populate("Health Potions", preload("res://items/health_potion.tscn"), preload("res://assets/items/healthpotion/tile.png"), 0, 1, -2)
				tooltip = "Restores 2 HP.\nHey, I get it. Sometimes you make mistakes. Consider this an oopsie button."
			ItemNames.MANA_POTION:
				populate("Mana Potions", preload("res://items/mana_potion.tscn"), preload("res://assets/items/manapotion/tile.png"), -1)
				tooltip = "Restores 1 Mana.\nMore Mana, More Dakka."
			ItemNames.FIRE_BOMB:
				populate("Fire Bombs", preload("res://items/thrown_item.tscn"), preload("res://assets/items/firebomb/tile.png"), 0, 1, 1, 5, 0.8, 1)
				tooltip = "Counterspell this, casual. Smaller boom than a fireball but still effective."
			ItemNames.SCROLL:
				spell = Spell.Spell.new(spell_in)
				populate(spell.name, spell.spell_node, preload("res://assets/items/mysteryspell/tile.png"), spell.cost - 1, 1, spell.damage, spell.range, spell.hit_chance, spell.radius)
				tooltip = "the Cheat-code of wizard fights. Catch them off guard with this little bonus."
	
	func populate(new_name, new_item_node, new_icon, new_cost, new_quantity = 1, new_damage = 0, new_range = 0, new_hit_chance = 1, new_radius = 0):
		name = new_name
		item_node = new_item_node
		icon = new_icon
		cost = new_cost
		quantity = new_quantity
		damage = new_damage
		range = new_range
		hit_chance = new_hit_chance
		radius = new_radius
