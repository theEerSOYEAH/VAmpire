extends TextureProgressBar

var last_exp: int = 0
var is_leveling_up: bool = false

func  _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var player = get_tree().get_first_node_in_group("player")
	if player:
		max_value = player.max_xp
		value = player.current_xp
		last_exp = player.current_xp

func _physics_process(delta: float) -> void:
	if is_leveling_up:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	if player.current_xp != last_exp:
		if player.current_xp < last_exp:
			is_leveling_up = true
			
			var old_max = max_value
			var fill_tween = create_tween().bind_node(self)
			fill_tween.tween_property(self, "value", old_max, 0.35)
			await fill_tween.finished
			
			while get_tree().paused:
				await get_tree().process_frame
			
			max_value = old_max
			value = old_max
			var draind_tween = create_tween().bind_node(self).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			draind_tween.tween_property(self, "value", float(player.current_xp), 1.5)
			await  draind_tween.finished
			
			max_value = player.max_xp
			
			last_exp = player.current_xp
			is_leveling_up = false
			return
			
			
		last_exp = player.current_xp
		max_value = player.max_xp
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).bind_node(self)
		tween.tween_property(self, "value", float(player.current_xp), 0.55)
