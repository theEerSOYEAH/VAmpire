extends CharacterBody2D

@export var contact_damage: int = 1
@export var speed: float = 100.0
@export var max_health: float = 100.0
@export var knockback_force: float = 600.0


var current_health: float 
var player_ref: Area2D = null
var player: CharacterBody2D = null
var knockback: Vector2 =Vector2.ZERO
var is_dying: bool = false

@onready var hitbox: Area2D = $Hitbox
@onready var damage_timer: Timer = $DamageTimer

func _ready() -> void:
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	hitbox.area_exited.connect(_on_hitbox_area_exited)
	damage_timer.timeout.connect(_on_damage_timer_timeout)

func _on_hitbox_area_entered(area: Area2D) -> void:
	var target = area.owner
	if target and target.is_in_group("player"):
		player_ref = area
		deal_damage()
		damage_timer.start()

func _on_hitbox_area_exited(area: Area2D) -> void:
	if area == player_ref:
		player_ref = null
		damage_timer.stop()

func _on_damage_timer_timeout() -> void:
	deal_damage()

func deal_damage() -> void:
	if is_instance_valid(player_ref):
		var target = player_ref.owner
		if target and target.has_method("take_damage"):
			target.take_damage(contact_damage)
		

func _physics_process(delta: float) -> void:
	if is_dying:
		return
	
	
	if player:
		var kb_direction := global_position.direction_to(player.global_position)
		
		knockback = knockback.lerp(Vector2.ZERO, 10.0 * delta)
		
		velocity = (kb_direction * speed) + knockback
		move_and_slide()
		
		if kb_direction.x > 0:
			$AnimatedSprite2D.flip_h = false
		elif kb_direction.x < 0:
			$AnimatedSprite2D.flip_h = true

func take_damage(amount: float) -> void:
	current_health -= amount
	if current_health <= 0:
		die()
	else:
		$AnimatedSprite2D.play("hurt")
		await $AnimatedSprite2D.animation_finished
		$AnimatedSprite2D.play("default")
		


func apply_knockback(_source_position: Vector2) -> void:
	if is_instance_valid(player):
		var knockback_direction = player.global_position.direction_to(global_position)
		knockback = knockback_direction * knockback_force

func die() -> void:
	if is_dying:
		return
	is_dying = true
	
	$Hitbox.monitoring = false
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	
	$AnimatedSprite2D.play("die")
	
	await $AnimatedSprite2D.animation_finished
	queue_free()


		
