extends Node


var killed_enemies : int = 0
var combo_count:int = 0
var combo_time_limit = 5
var combo_timer = Timer




signal kill_count_updated(new_count: int)
signal combo_updated(new_combo: int)

func _ready() -> void:
	combo_timer = Timer.new()
	combo_timer.wait_time = combo_time_limit
	combo_timer.one_shot = true
	combo_timer.timeout.connect(_on_combo_timeout)
	add_child(combo_timer)
	
func add_kill():
	killed_enemies += 1
	combo_count += 1
	
	combo_timer.start(combo_time_limit)
	
	emit_signal("combo_updated",combo_count)
	emit_signal("kill_count_updated", killed_enemies)

func _on_combo_timeout():
	combo_count = 0
	emit_signal("combo_updated",combo_count)
