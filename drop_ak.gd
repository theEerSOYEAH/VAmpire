extends Area2D






func _on_body_entered(body: Node2D) -> void:
	print("1212121212221212")
	if body.is_in_group("player"):
		if body.has_method("unlock_ak47"):
			body.unlock_ak47()
		
		
		queue_free()
