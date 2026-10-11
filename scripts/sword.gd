extends Area2D

@export var damage: float = 25.0
@export var swing_angle: float = 120.0
@export var swing_time: float = 0.15

var attacking: bool = false
var hit_enemies: Array = []


@export var slash_scene : PackedScene


func attack() -> void:
	print ("sword attack called fr fr"
	)
	if attacking:
		return

	if slash_scene == null:
		return

	var slash = slash_scene.instantiate() 
	get_tree().current_scene.add_child(slash)
	var direction = (get_global_mouse_position() - global_position).normalized()
	slash.global_position = global_position + direction * 20
	slash.global_rotation = (get_global_mouse_position() - slash.global_position).angle()
	$slash.play()
	
	await get_tree().create_timer(0.15).timeout
	attacking = false





func _on_body_entered(body: Node2D) -> void:
	print("entered", body.name)

	if not attacking:
		return

	if body.is_in_group("enemy"):
		print("Enemy hit!")

		if body not in hit_enemies:
			body.take_damage(damage)
			hit_enemies.append(body)
