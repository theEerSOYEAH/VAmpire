extends Area2D


@export var duration = 15 



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("activate_luck"):
			body.activate_luck(duration)
			queue_free()
