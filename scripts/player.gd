extends CharacterBody2D

signal health_changed

@onready var cooldown_label: Label = $Label

@export var shoot_cooldown = 0.4
var shoot_timer = 0

@export var ak_shoot_cooldown = 0.1
var ak_shoot_timer = 0

@export var bullet_scene: PackedScene
@onready var gun: Node2D =  $hand/gun
@onready var sword = $hand/sword
@onready var muzzle: Marker2D = $hand/gun/Muzzle
@onready var hand = $hand
@onready var ak47 = $hand/ak47
@onready var ak_muzzle = $"hand/ak47/muzzle ak"



@export var gun_hand_distance:float = 5
@export var sword_hand_distance:float = 2


var current_weapon = "gun"
var ak_unlocked = false

@export var max_health: int = 3
var current_health: int = 3

var speed: float  = 200
var dash_speed = 800
var dash_time = 0.2

var dash_timer = 0
var dash_direction = Vector2.ZERO

var cooldown_timer = 0
@export var dash_cooldown = 5

var base_speed: float = 200

var luck_multiplier = 1
var luck_activate = false



func activate_luck(duration):
	luck_multiplier = 2
	luck_activate = true
	
	print("LUCK ACTIVATED! Multiplier: ", luck_multiplier)
	
	await get_tree().create_timer(duration).timeout
	
	luck_multiplier = 1
	luck_activate = false
	
	print("lucke ended homie")

func speed_boost(amount: float, duration: float):
	print("DEDECTED")
	speed = base_speed + amount
	
	await get_tree().create_timer(duration).timeout
	
	speed = base_speed

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
	
	if ak_shoot_timer > 0:
		ak_shoot_timer -= delta
	
	if cooldown_timer > 0:
		cooldown_timer -= delta
		cooldown_label.text = "%.1f" %cooldown_timer
	else:
		cooldown_label.text = ""

	if current_weapon == "gun":
		if Input.is_action_pressed("shoot") and shoot_timer <= 0:
			shoot()
			shoot_timer = shoot_cooldown

	if current_weapon == "ak47":
		if Input.is_action_pressed("shoot") and ak_shoot_timer <= 0:
			shoot_ak47()
			ak_shoot_timer = ak_shoot_cooldown

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
	


func take_damage(amount: int):
	if dash_timer > 0:
		return
	
	current_health -= amount
	health_changed.emit()
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

	bullet.global_position = gun.global_position
	bullet.look_at(get_global_mouse_position())

	get_tree().current_scene.add_child(bullet)
	$Camera2D.shake()


func shoot_ak47():
	if not bullet_scene:
		return
	
	var bullet = bullet_scene.instantiate()
	
	bullet.global_position = ak_muzzle.global_position
	bullet.look_at(get_global_mouse_position())
	bullet.damage = 7.5
	
	get_tree().current_scene.add_child(bullet)
	
	$Camera2D.shake()


func _process(_delta):
	# Sword attack
	if Input.is_action_just_pressed("attack"):
		if current_weapon == "sword":
			sword.attack()

	# Switch weapon
	if Input.is_action_just_pressed("switch_weapon"):
		switch_weapon()
			
			


func switch_weapon():
	shoot_timer = 0
	ak_shoot_timer = 0

	if current_weapon == "gun":
		if ak_unlocked:
			current_weapon = "ak47"

			gun.visible = false
			ak47.visible = true
			sword.visible = false

			hand.current_distance = gun_hand_distance
		else:
			current_weapon = "sword"

			gun.visible = false
			ak47.visible = false
			sword.visible = true

			hand.current_distance = sword_hand_distance

	elif current_weapon == "ak47":
		current_weapon = "sword"

		gun.visible = false
		ak47.visible = false
		sword.visible = true

		hand.current_distance = sword_hand_distance

	else:
		current_weapon = "gun"

		gun.visible = true
		ak47.visible = false
		sword.visible = false

		hand.current_distance = gun_hand_distance


func unlock_ak47():
	ak_unlocked = true
	print("ak_unlocked")



func heal(amount):
	current_health = min(current_health + amount, max_health)
	health_changed.emit()
	

func _ready():
	current_health = max_health
	gun.visible = true
	ak47.visible = false
	sword.visible = false
	hand.current_distance = gun_hand_distance
