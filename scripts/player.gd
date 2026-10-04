extends CharacterBody2D

signal health_changed

@onready var cooldown_label: Label = $Label
@onready var blood_particles: CPUParticles2D = $CPUParticles2D

@export var game_over_scene: PackedScene

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

var is_hurt: bool = false
var is_dying: bool = false

var cooldown_timer = 0
@export var dash_cooldown = 5

func _physics_process(delta):
	if is_dying:
		return
		
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
	if not is_hurt:
		if direction != Vector2.ZERO:
			$AnimatedSprite2D.play("Move")
		else:
			$AnimatedSprite2D.play("idle")
	
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
	if dash_timer > 0 or is_dying:
		return
	
	current_health -= amount
	health_changed.emit()
	print("player health: ", current_health)
	
	if current_health <= 0:
		die()
	else:
		is_hurt = true
		blood_particles.restart()
		if has_node("Camera2D"):
			$Camera2D.shake()
			
		$AnimatedSprite2D.play("hurt")
		await  $AnimatedSprite2D.animation_finished
		is_hurt = false
	
	
func die():
	if is_dying:
		return
	is_dying = true
	print("you died")
	
	$AnimatedSprite2D.play("die")
	await $AnimatedSprite2D.animation_finished
	
	if game_over_scene:
		var game_over_menu = game_over_scene.instantiate()
		get_tree().current_scene.add_child(game_over_menu)
		
		get_tree().paused = true

func shoot():
	if not bullet_scene:
		return
	
	var bullet = bullet_scene.instantiate()
	
	bullet.global_position = muzzle.global_position
	
	bullet.look_at(get_global_mouse_position())
	
	get_tree().current_scene.add_child(bullet)
	$Camera2D.shake()
