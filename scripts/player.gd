extends CharacterBody2D

@onready var cooldown_label: Label = $Label

@export var shoot_cooldown = 0.4
var shoot_timer = 0

@export var bullet_scene: PackedScene
@onready var muzzle: Marker2D =  $hand/Muzzle

@export var max_health: int = 3
var current_health: int = 3

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
	
	if direction.x > 0:
		$AnimatedSprite2D.flip_h = false
	elif  direction.x < 0:
		$AnimatedSprite2D.flip_h = true
	
	if shoot_timer > 0:
		shoot_timer -= delta
	
	if cooldown_timer > 0:
		cooldown_timer -= delta
		cooldown_label.text = "%.1f" %cooldown_timer
	else:
		cooldown_label.text = ""

	if Input.is_action_pressed("shoot") and shoot_timer <= 0:
		shoot()
		shoot_timer = shoot_cooldown

	if Input.is_action_just_pressed("dash"):
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
	

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int):
	if dash_timer > 0:
		return
	
	current_health -= amount
	print("player health: ", current_health)
	
	if current_health <= 0:
		die()
	
func die():
	print("you died")
	get_tree().reload_current_scene()


func shoot():
	if not bullet_scene:
		return
	
	var bullet = bullet_scene.instantiate()
	
	bullet.global_position = muzzle.global_position
	
	bullet.look_at(get_global_mouse_position())
	
	get_tree().current_scene.add_child(bullet)
	$Camera2D.shake()
