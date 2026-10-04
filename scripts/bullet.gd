extends Area2D

@export var speed: float = 600.0
@export var damage: float = 10.0
@export var hit_particles: PackedScene

func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		return
	
	if body.has_method("take_damage"):
		body.take_damage(damage)
		
		if body.has_method("apply_knockback"):
			body.apply_knockback(global_position)
		
		if hit_particles:
			var particles = hit_particles.instantiate()
			particles.global_position = global_position
			get_tree().current_scene.add_child(particles)
		queue_free()
	else:
		queue_free()
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
