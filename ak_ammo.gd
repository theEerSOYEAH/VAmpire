extends Area2D

@export var collectable_ak_ammo = 20


func _on_body_entered(body: Node2D) -> void:
	
	print("smth enteredfr", body.name)
	
	if body.name == "player" and body.ak_unlocked:
		body.total_ak_ammo += collectable_ak_ammo
		if body.has_method("update_ammo_ui"):
			body.update_ammo_ui()
		
		visible = false
		queue_free()
