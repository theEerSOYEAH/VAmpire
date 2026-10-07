extends Area2D

@export var collectable_ak_ammo = 20


func _on_body_entered(body: Node2D) -> void:
	
	print("smth enteredfr", body.name)
	
	if body.name == "player" and body.ak_unlocked:
		body.total_ak_ammo += collectable_ak_ammo
		if body.current_weapon == "ak47":
			body.get_node("Label2").text = str(body.current_ak_ammo,"/",body.total_ak_ammo)
		visible = false
		queue_free()
