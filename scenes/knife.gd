extends Node2D

@export var projectile_scene: PackedScene
@export var fire_rate: float = 1.0
@export var orbit_radius: float = 50.0
@export var orbit_speed: float = 2.0
@export var detection_radius: float = 300.0

var current_orbit_angle: float = 0.0
var fire_timer: float = 0.0

func _physics_process(delta: float) -> void:
	current_orbit_angle += orbit_speed * delta
	if current_orbit_angle >= TAU:
		current_orbit_angle -= TAU
		
	position = Vector2(cos(current_orbit_angle), sin(current_orbit_angle)) * orbit_radius
	
	fire_timer += delta
	if fire_timer >= fire_rate:
		fire_timer = 0.0
		try_fire_at_nearest_enemy()

func try_fire_at_nearest_enemy() -> void:
	var nearest_enemy = get_nearest_enemy()
	if nearest_enemy and projectile_scene:
		var proj = projectile_scene.instantiate()
		proj.global_position = global_position
		proj.direction = (nearest_enemy.global_position - global_position).normalized()
		get_tree().current_scene.add_child(proj)

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
		
	
	
	
	
	
