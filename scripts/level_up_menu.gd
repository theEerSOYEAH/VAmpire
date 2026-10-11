extends CanvasLayer

@onready var background = $Background
@onready var card_health = $Card
@onready var card_speed = $CardSpeed
@onready var card_knife = $Card_Knife_Unlock

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	background.modulate.a = 0.0
	card_health.modulate.a = 0.0
	card_speed.modulate.a = 0.0
	card_knife.modulate.a = 0.0
	
	card_health.pressed.connect(_on_health_card_pressed)
	card_speed.pressed.connect(_on_speed_card_pressed)
	card_knife.pressed.connect(_on_knife_card_pressed)
	
	await get_tree().process_frame
	for card in [card_health, card_speed, card_knife]:
		card.pivot_offset = card.size / 2
		card.mouse_entered.connect(func(): _scale_card(card, Vector2(1.08, 1.08), 0.15))
		card.mouse_exited.connect(func(): _scale_card(card, Vector2(1.0, 1.0), 0.15))

func _scale_card(card: Control, target_scale: Vector2, duration: float) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "scale", target_scale, duration)

func show_menu() -> void:
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	for card in [card_health, card_speed, card_knife]:
		card.scale = Vector2.ONE
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(background, "modulate:a", 1.0, 0.3)
	tween.tween_property(card_health, "modulate:a", 1.0, 0.3)
	tween.tween_property(card_speed, "modulate:a", 1.0, 0.3)
	tween.tween_property(card_knife, "modulate:a", 1.0, 0.3)

func hide_menu() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(background, "modulate:a", 0.0, 0.2)
	tween.tween_property(card_health, "modulate:a", 0.0, 0.2)
	tween.tween_property(card_speed, "modulate:a", 0.0, 0.2)
	tween.tween_property(card_knife, "modulate:a", 0.0, 0.2)
	
	await tween.finished
	visible = false
	get_tree().paused = false
	
func _on_health_card_pressed() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.max_health += 1
		player.current_health += 1
		print("upgraded health")
		hide_menu()
func _on_speed_card_pressed() -> void:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.speed += 20.0
			print("upgraded speed")
			hide_menu()
func _on_knife_card_pressed() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.unlock_knife()
		hide_menu()
		
