extends Node2D

var current_distance: float = 5.0


func _process(_delta):
	var mouse_dir = (
		get_global_mouse_position() - get_parent().global_position
	).normalized()

	position = mouse_dir * current_distance
	rotation = mouse_dir.angle()
