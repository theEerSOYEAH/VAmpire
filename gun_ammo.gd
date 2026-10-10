extends Area2D

@export var collectable_ammo = 20


@onready var label_2: Label = $Label2

func _on_body_entered(body: Node2D) -> void:
	print("smth enter",body.name)
	if body.name == "player":
		body.total_gun_ammo += collectable_ammo
		if body.current_weapon == "gun":
			body.get_node("Label2").text = str(body.current_gun_amo,"/",body.total_gun_ammo)
		queue_free()
		visible = false
