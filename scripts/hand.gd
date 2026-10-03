extends Node2D

@export var hand_distance = 5.0

func _process(_delta):
	var mouse_dir = (get_global_mouse_position() - get_parent().global_position).normalized()

	position = mouse_dir * hand_distance
	rotation = mouse_dir.angle()
