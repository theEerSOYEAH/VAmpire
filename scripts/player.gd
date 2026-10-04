extends CharacterBody2D

@onready var cooldown_label: Label = $Label

@export var shoot_cooldown = 0.4
var shoot_timer = 0

@export var bullet_scene: PackedScene
@onready var gun: Node2D =  $hand/gun
@onready var sword = $hand/sword
@onready var muzzle: Marker2D = $hand/gun/Muzzle
@onready var hand = $hand

@export var gun_hand_distance:float = 5
@export var sword_hand_distance:float = 2


var current_weapon = "gun"

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

	if current_weapon == "gun":
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
	
func shoot():
	if not bullet_scene:
		return

	var bullet = bullet_scene.instantiate()

	bullet.global_position = gun.global_position
	bullet.look_at(get_global_mouse_position())

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
	if current_weapon == "gun":
		current_weapon = "sword"
		gun.visible = false
		sword.visible = true
		hand.current_distance = sword_hand_distance
	else:
		current_weapon = "gun"
		gun.visible = true
		sword.visible = false
		hand.current_distance = gun_hand_distance



func _ready():
	gun.visible = true
	sword.visible = false
	hand.current_distance = gun_hand_distance
