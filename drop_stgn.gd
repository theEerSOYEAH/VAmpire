extends Area2D




func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("unlock_stgn"):
			body.unlock_stgn()
			print("3254")
		
		queue_free()
