extends CharacterBody2D




@export var luck_potion_scene: PackedScene
@export var projectile_scene: PackedScene
@export var shooting_range: float = 200.0
@export var retreat_distance: float = 150.0
@export var max_health: float = 10.0
@onready var muzzle: Marker2D = $Muzzle
@onready var shoot_timer: Timer = $ShootTimer
@onready var charge_sprite: Sprite2D = $Muzzle/ChargeSprite

var current_health: float = 10.0
var speed: float = 100.0
var player = null

func  _ready() -> void:
	current_health = max_health
	player = get_tree().current_scene.find_child("player", true, false)
	shoot_timer.timeout.connect(start_charge)

func start_charge() -> void:
	charge_sprite.visible = true
	charge_sprite.scale = Vector2(2.0, 2.0)
	
	var tween = create_tween()
	
	tween.tween_property(charge_sprite, "scale", Vector2(0.5, 0.5), 0.5)
	
	tween.finished.connect(shoot)

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	
	
	var direction = global_position.direction_to(player.global_position)
	var distance = global_position.distance_to(player.global_position)
	
	if distance > shooting_range:
		velocity = direction * speed
	elif distance < retreat_distance:
		velocity = -direction * speed
	else:
		velocity = Vector2.ZERO
	
	if direction.x > 0:
		$AnimatedSprite2D.flip_h = false
		$Muzzle.position.x = 7.0
	elif direction.x < 0:
		$AnimatedSprite2D.flip_h = true
		$Muzzle.position.x = -7.0
		
	move_and_slide()
	
func  shoot() -> void:
	charge_sprite.visible = false
	
	if not is_instance_valid(player) or not projectile_scene:
		return
	
	var proj = projectile_scene.instantiate()
	
	proj.global_position = muzzle.global_position
	
	proj.look_at(player.global_position)
	
	get_tree().current_scene.add_child(proj)
	
func take_damage(amount: int) -> void:
	current_health -= amount
	
	if current_health <= 0:
		die()

func die() -> void:
	$AnimatedSprite2D.play("die")
	await $AnimatedSprite2D.animation_finished
	drop_luck_potion()
	
	queue_free()


		
		
		
		

func drop_luck_potion():
	if luck_potion_scene == null:
		return
	
	var potion = luck_potion_scene.instantiate()
	potion.global_position =  global_position
	get_tree().current_scene.add_child(potion)
