extends CharacterBody2D

signal health_changed

var total_gun_ammo = 80
var total_ak_ammo = 180
var total_stgn_ammo = 30

var gun_mag = 20
var ak_mag = 30
var stgn_mag = 6

var current_gun_amo = 20
var current_ak_ammo = 30
var current_stgn_ammo = 6

@onready var cooldown_label: Label = $Label
@onready var blood_particles: CPUParticles2D = $CPUParticles2D
@onready var potion_particles: CPUParticles2D = $health_particle
@onready var speed_particles: CPUParticles2D = $speed_particle
@onready var luck_particles: CPUParticles2D = $luck_particle

@export var game_over_scene: PackedScene

@export var shoot_cooldown = 0.4
var shoot_timer = 0

@export var ak_shoot_cooldown = 0.1
var ak_shoot_timer = 0

@export var stgn_shoot_cooldown = 0.5
var stgn_shoot_timer = 0

@export var bullet_scene: PackedScene
@onready var gun: Node2D =  $hand/gun
@onready var sword = $hand/sword
@onready var muzzle: Marker2D = $hand/gun/Muzzle
@onready var hand = $hand
@onready var ak47 = $hand/ak47
@onready var ak_muzzle = $"hand/ak47/muzzle ak"
@onready var stgn: Node2D = $hand/shotgun
@onready var muzzle_stgn: Marker2D = $"hand/shotgun/muzzle shotgun"




@export var gun_hand_distance:float = 5
@export var sword_hand_distance:float = 2
@export var ak_hand_distance = 3
@export var stgn_hand_distance =3


@export var stgn_pellets = 6
@export var stgn_spread:float = 25
@export var stgn_damage:float = 5.0


var current_weapon = "gun"
@export var ak_unlocked = false
@export var stgn_unlocked = false

@export var max_health: int = 3
var current_health: int = 3

var speed: float  = 200
var dash_speed = 800
var dash_time = 0.2

var dash_timer = 0
var dash_direction = Vector2.ZERO

var is_hurt: bool = false
var is_dying: bool = false

var cooldown_timer = 0
@export var dash_cooldown = 5

var base_speed: float = 200

var luck_multiplier = 1
var luck_activate = false



func reload():
	var needed_gun_ammo = gun_mag - current_gun_amo
	var ammo_to_reload = min(needed_gun_ammo,total_gun_ammo)
	
	total_gun_ammo -= ammo_to_reload
	current_gun_amo += ammo_to_reload
	$Label2.text = str(current_gun_amo,"/",total_gun_ammo)

func stgn_reload():
	var needed_stgn_ammo = stgn_mag - current_stgn_ammo
	var stgn_ammo_to_reload = min(needed_stgn_ammo,total_stgn_ammo)
	
	total_stgn_ammo -= stgn_ammo_to_reload
	current_stgn_ammo += stgn_ammo_to_reload
	$Label2.text = str(current_stgn_ammo,"/",total_stgn_ammo)



func ak_reload():
	var needed_ak_ammo = ak_mag - current_ak_ammo
	var ak_ammo_to_reload = min(needed_ak_ammo,total_ak_ammo)
	
	total_ak_ammo -= ak_ammo_to_reload
	current_ak_ammo += ak_ammo_to_reload
	$Label2.text = str("ak" ,current_ak_ammo,"/",total_ak_ammo)

func activate_luck(duration):
	luck_multiplier = 2
	luck_activate = true
	
	print("LUCK ACTIVATED! Multiplier: ", luck_multiplier)
	luck_particles.restart()
	await get_tree().create_timer(duration).timeout
	
	luck_multiplier = 1
	luck_activate = false
	
	print("lucke ended homie")

func speed_boost(amount: float, duration: float):
	print("DEDECTED")
	speed = base_speed + amount
	
	speed_particles.restart()
	
	await get_tree().create_timer(duration).timeout
	
	speed = base_speed

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
	
	if ak_shoot_timer > 0:
		ak_shoot_timer -= delta
	
	if stgn_shoot_timer > 0:
		stgn_shoot_timer -= delta
	
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


	if current_weapon == "stgn":
		if Input.is_action_just_pressed("shoot") and stgn_shoot_timer <= 0:
			shoot_stgn()
			stgn_shoot_timer = stgn_shoot_cooldown




	if Input.is_action_just_pressed("dash"):
		
		$dash_sound.play()
		
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
	if current_gun_amo > 0:
		var bullet = bullet_scene.instantiate()
		$gunshot.play()
		bullet.global_position = gun.global_position
		bullet.look_at(get_global_mouse_position())
		get_tree().current_scene.add_child(bullet)
		$Camera2D.shake()
		current_gun_amo -= 1
		$Label2.text = str(current_gun_amo,"/",total_gun_ammo)

func shoot_ak47():
	if not bullet_scene:
		return
	
	if current_ak_ammo > 0:
		var bullet = bullet_scene.instantiate()
		$gunshot.play()
		bullet.global_position = ak_muzzle.global_position
		bullet.look_at(get_global_mouse_position())
		bullet.damage = 7.5
		get_tree().current_scene.add_child(bullet)
		$Camera2D.shake()
		current_ak_ammo -= 1
		$Label2.text = str("ak", current_ak_ammo,"/",total_ak_ammo)


func shoot_stgn():
	if not bullet_scene:
		return
	
	if current_stgn_ammo <= 0:
		return
	
	for i in stgn_pellets:
		var bullet = bullet_scene.instantiate()
		
		var direction = (
			get_global_mouse_position() - muzzle_stgn.global_position
		).normalized()
		
		var spread = deg_to_rad(
			randf_range(-stgn_spread, stgn_spread)
		)
		
		direction = direction.rotated(spread)
		
		bullet.rotation = direction.angle()
		bullet.damage = stgn_damage
		get_tree().current_scene.add_child(bullet)
		
		bullet.global_position = muzzle_stgn.global_position
		
		
		
		
		
		
		
		
	
	
	current_stgn_ammo -= 1
	$Camera2D.shake()
	$Label2.text = str(current_stgn_ammo,"/",total_stgn_ammo)

func _process(_delta):
	# Sword attack
	if Input.is_action_just_pressed("attack"):
		if current_weapon == "sword":
			sword.attack()

	# Switch weapon
	if Input.is_action_just_pressed("switch_weapon"):
		switch_weapon()
			
			

	if Input.is_action_just_pressed("reload"):
		if current_weapon == "gun":
			reload()
		elif current_weapon == "ak47":
			ak_reload()
		elif current_weapon == "stgn":
			stgn_reload()

func switch_weapon():
	shoot_timer = 0
	ak_shoot_timer = 0
	stgn_shoot_timer = 0

	if current_weapon == "gun":
		if ak_unlocked:
			current_weapon = "ak47"

			gun.visible = false
			ak47.visible = true 
			stgn.visible = false
			sword.visible = false
			$Label2.text = str("ak", current_ak_ammo,"/",total_ak_ammo)

			hand.current_distance = ak_hand_distance
		
		elif stgn_unlocked:
			current_weapon = "stgn"
			stgn.visible = true
			sword.visible = false
			gun.visible= false
			ak47.visible = false
			$Label2.text = str(current_stgn_ammo, "/", total_stgn_ammo)
			hand.current_distance = stgn_hand_distance
		
		
		else:
			current_weapon = "sword"

			gun.visible = false
			ak47.visible = false
			sword.visible = true
			stgn.visible = false
			$Label2.text = str(" ")

			hand.current_distance = sword_hand_distance

	elif current_weapon == "ak47":
		if stgn_unlocked:
			current_weapon = "stgn"

			gun.visible = false
			ak47.visible = false
			sword.visible = false
			stgn.visible = true
			$Label2.text = str(current_stgn_ammo,"/",total_stgn_ammo)

			hand.current_distance = stgn_hand_distance


		else:
			current_weapon = "sword"
			gun.visible = false
			sword.visible = true
			ak47.visible = false
			stgn.visible = false





	elif current_weapon == "stgn":
		current_weapon = "sword"
		
		gun.visible = false
		ak47.visible = false
		stgn.visible = false
		sword.visible = true	

	else:
		current_weapon = "gun"

		gun.visible = true
		ak47.visible = false
		sword.visible = false
		$Label2.text = str(current_gun_amo ,"/",total_gun_ammo)

		hand.current_distance = gun_hand_distance


func unlock_ak47():
	ak_unlocked = true
	print("ak_unlocked")

func unlock_stgn():
	stgn_unlocked = true

func heal(amount):
	current_health = min(current_health + amount, max_health)
	health_changed.emit()
	
	potion_particles.restart()
	

func _ready():
	$Label2.text = str(current_ak_ammo,"/",total_ak_ammo)
	current_health = max_health
	gun.visible = true
	ak47.visible = false
	sword.visible = false
	stgn.visible = false
	hand.current_distance = gun_hand_distance
