extends CanvasLayer

@onready var card_health = $Card
@onready var card_speed = $CardSpeed
@onready var card_knife = $Card_Knife_Unlock

func _ready() -> void:
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	card_health.pressed.connect(_on_health_card_pressed)
	card_speed.pressed.connect(_on_speed_card_pressed)
	card_knife.pressed.connect(_on_knife_card_pressed)
	
func _on_health_card_pressed() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.max_health += 1
		player.current_health += 1
		print("upgraded health")
		get_tree().paused = false
		queue_free()
func _on_speed_card_pressed() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.speed += 20.0
		print("upgraded speed")
		get_tree().paused = false
		queue_free()
func _on_knife_card_pressed() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.unlock_knife()
	get_tree().paused = false
	queue_free()
