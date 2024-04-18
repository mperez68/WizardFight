extends ItemNode

func _ready():
	item = Item.Item.new(Item.ItemNames.FIRE_BOMB)

func start(target_body: CharacterBody2D, origin: Vector2, origin_height = 64):
	super(target_body, origin, origin_height)
	rotation = 0
