extends Area2D




func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" and body.stgn_unlocked:
		body.total_stgn_ammo += body.current_stgn_ammo
		if body.current_weapon == "stgn":
			body.get_node("Label2").text = str(body.current_stgn_ammo,"/",body.total_stgn_ammo)
		
		visible = false
		queue_free()
