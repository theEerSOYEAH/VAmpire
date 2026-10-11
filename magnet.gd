extends Area2D

@export var magnet_dur = 3
@export var pull_speed = 350




func _ready() -> void:
	body_entered.connect(_on_body_entered)



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if is_in_group("loot"):
			remove_from_group("loot")
		visible = false
		set_deferred("monitoring", false)
		set_deferred("monitoring", false)
		
		var camera = get_tree().get_first_node_in_group("camera") as Camera2D
		if camera and camera.has_method("shake"):
			camera.shake()
			
			start_pulling_all_loot(body)

func start_pulling_all_loot(player: Node2D):
	var time_left = magnet_dur
	while time_left >0 and is_instance_valid(player):
		var delta = get_process_delta_time()
		time_left -= delta
		
		var loot_items = get_tree().get_nodes_in_group("loot")
		
		for item in loot_items:
			if is_instance_valid(item) and item != self and not item.is_queued_for_deletion():
				
				if item.name.to_lower().contains("magnet"):
					continue
				
				
				item.global_position = item.global_position.move_toward(
					player.global_position,
					pull_speed * delta
				)
		await  get_tree().process_frame
	queue_free()
