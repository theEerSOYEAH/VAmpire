extends Area2D

@export var speed_bonus: float = 150
@export var duration: float = 5



func _on_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.is_in_group("player"):
		if body.has_method("speed_boost"):
			body.speed_boost(speed_bonus, duration)
			queue_free()
