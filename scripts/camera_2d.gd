extends Camera2D

var strength = 2
var shake_offset = Vector2.ZERO
var shake_max_time = 0.2
var shake_timer = 0

var player = null

func _ready() -> void:
	if not is_instance_valid(player):
		player = get_tree().current_scene.find_child("player", true, false)
		if not is_instance_valid(player):
			return

func _process(delta: float) -> void:
	if shake_timer > 0:
		shake_offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		shake_timer -= delta
	else:
		shake_offset = Vector2.ZERO
		
	
func shake():
	shake_timer = shake_max_time
