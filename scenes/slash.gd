extends Area2D

@export var damage:float = 25
@export var lifetime:float = 0.15

var hit_enemies : Array[Node2D] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(lifetime).timeout
	queue_free()




func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body not in hit_enemies:
		if body.has_method("take_damage"):
			hit_enemies.append(body)
			body.take_damage(damage)
