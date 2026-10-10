extends Area2D

var collectable_stgn_ammo: int = 6


func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" and body.stgn_unlocked:
		body.total_stgn_ammo += collectable_stgn_ammo
		
		if body.current_weapon == "stgn":
			var ammo_label = body.get_node_or_null("CanvasLayer/ammo_label")
			if ammo_label:
				ammo_label.text = str(body.current_stgn_ammo, "/", body.total_stgn_ammo )
		
		visible = false
		queue_free()
