extends Line2D

@export var max_length: int = 15

func _ready() -> void:
	clear_points()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	add_point(get_parent().global_position)
	
	if get_point_count() > max_length:
		remove_point(0)
