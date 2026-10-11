extends Area2D


@export var freeze_dur : float = 3.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		freeze_all_enemies()
		queue_free()

func freeze_all_enemies():
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.has_method("freeze"):
			enemy.freeze(freeze_dur)
