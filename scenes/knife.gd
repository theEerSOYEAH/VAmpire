extends Area2D

@export var speed: float = 600.0
@export var damage: int = 10
@export var orbit_radius: float = 50.0
@export var orbit_speed: float = 2.0
@export var detection_radius: float = 300.0
@export var cooldown_time: float = 0.8
@export var hit_particles: PackedScene

enum  State { ORBITING, FIRING, COOLDOWN}
var current_state: State = State.ORBITING

var current_orbit_angle: float = 0.0
var fire_direction: Vector2 = Vector2.RIGHT

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func  _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
func _physics_process(delta: float) -> void:
	match  current_state:
		State.ORBITING:
			_process_orbit(delta)
			_check_for_targets()
		State.FIRING:
			global_position += fire_direction * speed * delta
			if global_position.distance_to(get_parent().global_position) > detection_radius * 1.5:
				start_cooldown()
		State.COOLDOWN:
			pass

func _process_orbit(delta: float) -> void:
	current_orbit_angle += orbit_speed * delta
	if current_orbit_angle >= TAU:
		current_orbit_angle -= TAU
	
	var orbit_offset = Vector2(cos(current_orbit_angle), sin(current_orbit_angle)) * orbit_radius
	global_position = get_parent().global_position + orbit_offset
	
	rotation = current_orbit_angle + (PI / 2.0)

func _on_area_entered(area: Area2D) -> void:
	if current_state == State.FIRING and area.is_in_group("enemy"):
		if area.has_method("take_damage"):
			area.take_damage(damage)
		if hit_particles:
			var particles = hit_particles.instantiate()
			particles.global_position = global_position
			get_tree().current_scene.add_child(particles)
		start_cooldown()

func start_cooldown() -> void:
	current_state = State.COOLDOWN
	visible = false
	collision.set_deferred("disabled", true)
	
	await get_tree().create_timer(cooldown_time).timeout
	
	visible = true
	collision.set_deferred("disabled", false)
	current_state = State.ORBITING

func _check_for_targets() -> void:
	var nearest_enemy = get_nearest_enemy()
	if nearest_enemy:
		current_state = State.FIRING
		fire_direction = (nearest_enemy.global_position - global_position).normalized()
		rotation = fire_direction.angle()
		
func get_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemy")
	var nearest: Node2D = null
	var min_dist: float = detection_radius
	
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy
		
	return nearest
		

func _on_body_entered(body: Node2D) -> void:
	if current_state == State.FIRING and body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		
			if body.has_method("apply_knockback"):
				body.apply_knockback(global_position)

			if hit_particles:
				var particles = hit_particles.instantiate()
				particles.global_position = global_position
				get_tree().current_scene.add_child(particles)
		start_cooldown()
