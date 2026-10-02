extends CharacterBody2D


@export var speed: float = 200.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	velocity = input_direction * speed
	move_and_slide()
	
	if input_direction.x > 0:
		sprite.flip_h = false
	elif  input_direction.x < 0:
		sprite.flip_h = true
	
	if input_direction != Vector2.ZERO:
		sprite.play("Move")
	else:
		sprite.play("idle")
	
func _ready() -> void:
	add_to_group("player")
