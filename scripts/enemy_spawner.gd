extends Node2D

@export var waves: Array[WaveData] = []
@export var spawn_radius: float = 400.0

var loop_count: int = 0
var difficulty_multiplier: float = 1.0
var current_wave_index: int = 0
var active_spawn_groups: int = 0
var player: CharacterBody2D

@onready var spawn_timer: Timer = $SpawnTimer
@onready var wave_timer: Timer = $WaveTimer

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	
	if waves.size() > 0:
		start_wave()

func start_wave() -> void:
	if current_wave_index >= waves.size():
		current_wave_index = 0
		loop_count += 1
		difficulty_multiplier += 0.25
		print("looping waves! Loop tier: ", loop_count)
		
		
	var current_wave: WaveData = waves[current_wave_index]
	
	active_spawn_groups = current_wave.enemies.size()
	
	for config in current_wave.enemies:
		if config and config.enemy_scene:
			spawn_enemy_group(config, current_wave)
		else:
			active_spawn_groups -= 1
			
	if active_spawn_groups <= 0:
		wave_timer.start(current_wave.time_after_wave)
	

func spawn_enemy_group(config: EnemyConfig, current_wave: WaveData) -> void:
	for i in range(config.count):
		spawn_enemy(config.enemy_scene)
		
		await get_tree().create_timer(config.spawn_interval).timeout
		
	active_spawn_groups -= 1
	if active_spawn_groups == 0:
		wave_timer.start(current_wave.time_after_wave)

func _on_wave_timer_timeout() -> void:
	current_wave_index += 1
	start_wave()

func spawn_enemy(enemy_scene: PackedScene) -> void:
	if not player or not enemy_scene:
		return
	
	var enemy = enemy_scene.instantiate()
	enemy.player = player
	
	var random_angle := randf() * TAU
	var randomized_radius = spawn_radius + randf_range(-60.0, 60.0)
	var spawn_pos: Vector2 = player.global_position + Vector2(cos(random_angle), sin(random_angle)) * randomized_radius
	
	enemy.global_position = spawn_pos
	get_tree().current_scene.add_child(enemy)
		
		
		
		
