extends CharacterBody2D

@export var speed: float = 100.0
var player: CharacterBody2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player:
		var direction := global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
		
		if direction.x > 0:
			$AnimatedSprite2D.flip_h = false
		elif direction.x < 0:
			$AnimatedSprite2D.flip_h = true
