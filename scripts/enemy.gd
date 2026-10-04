extends CharacterBody2D

@export var speed: float = 100.0
@export var max_health: float = 100.0

var current_health: float 
var player: CharacterBody2D = null

func _ready() -> void:
	add_to_group("enemy")
	current_health = max_health
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

func take_damage(amount: float) -> void:
	current_health -= amount
	if current_health <= 0:
		die()
		
func die() -> void:
	queue_free()
