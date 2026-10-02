extends Node2D

@export var waves: Array[WaveData] = []
@export var spawn_radius: float = 400.0

var current_wave_index: int = 0
var wave_spawn_queue: Array[PackedScene] = []
var player: CharacterBody2D

@onready var spawn_timer: Timer = $SpawnTimer
@onready var wave_timer: Timer = $WaveTimer

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	
	if waves.size() > 0:
		start_wave()

func start_wave() -> void:
	if current_wave_index >= waves.size():
		print("All waves completed")
		return
		
	var current_wave: WaveData = waves[current_wave_index]
	
	wave_spawn_queue.clear()
	for config in current_wave.enemies:
		if config and config.enemy_scene:
			for i in range(config.count):
				wave_spawn_queue.append(config.enemy_scene)
			
	spawn_timer.wait_time = current_wave.spawn_interval
	spawn_timer.start()
	
func  _on_spawn_timer_timeout() -> void:
	if not wave_spawn_queue.is_empty():
		var next_enemy: PackedScene = wave_spawn_queue.pop_front()
		spawn_enemy(next_enemy)
	else:
		spawn_timer.stop()
		var current_wave: WaveData = waves[current_wave_index]
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
	var spawn_pos := player.global_position + Vector2(cos(random_angle), sin(random_angle)) * spawn_radius
	
	enemy.global_position = spawn_pos
	
	get_tree().current_scene.add_child(enemy)
	
		
		
		
		
