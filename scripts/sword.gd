extends Area2D

@export var damage: float = 25.0
@export var swing_angle: float = 120.0
@export var swing_time: float = 0.15

var attacking: bool = false
var hit_enemies: Array = []





func attack() -> void:
	print ("sword attack called fr fr"
	)
	if attacking:
		return

	attacking = true
	hit_enemies.clear()

	$slash.play()

	var start_rotation := rotation
	var end_rotation := start_rotation + deg_to_rad(swing_angle)

	var tween := create_tween()
	tween.tween_property(self, "rotation", end_rotation, swing_time / 2)
	tween.tween_property(self, "rotation", start_rotation, swing_time / 2)

	await tween.finished

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
