extends Area2D

@export var collectable_ammo: int = 20

func _on_body_entered(body: Node2D) -> void:
	print("smth enter",body.name)
	if body.name == "player":
		body.total_gun_ammo += collectable_ammo
		
		if body.current_weapon == "gun":
			var  ammo_label = body.get_node_or_null("CanvasLayer/ammo_label")
			if ammo_label:
				ammo_label = str(body.current_gun_amo, "/", body.total_gun_ammo)
		queue_free()
		visible = false
