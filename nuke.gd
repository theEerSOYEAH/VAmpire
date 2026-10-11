extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)




func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		trigger_screen_wipe()
		queue_free()


func trigger_screen_wipe():
	
	var camera = get_tree().get_first_node_in_group("camera") as Camera2D
	if camera and camera.has_method("nuke_shake"):
		camera.nuke_shake()
	
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	print("NUKEEEEEEEEEEEEEEEEEEEEEEEEEE")
	
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.has_method("die"):
			enemy.die(false)
