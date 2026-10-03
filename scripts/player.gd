extends CharacterBody2D

@onready var cooldown_label: Label = $Label


var speed = 200
var dash_speed = 800
var dash_time = 0.2

var dash_timer = 0
var dash_direction = Vector2.ZERO

var cooldown_timer = 0
@export var dash_cooldown = 5

func _physics_process(delta):
	var direction = Input.get_vector(
		"left",
		 "right",
		 "up",
		 "down"
		)

	if cooldown_timer > 0:
		cooldown_timer -= delta
		cooldown_label.text = "%.1f" %cooldown_timer
	else:
		cooldown_label.text = ""



	if Input.is_action_just_pressed("ui_dash"):
		if direction != Vector2.ZERO and cooldown_timer <= 0:
			dash_direction = direction
			dash_timer = dash_time
			cooldown_timer = dash_cooldown

	if dash_timer > 0:
		velocity = dash_direction * dash_speed
		dash_timer -= delta
	else:
		velocity = direction * speed

	move_and_slide()
