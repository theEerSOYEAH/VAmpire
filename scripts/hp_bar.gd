extends TextureProgressBar


func _ready() -> void:
	$"../..".health_changed.connect(update)
	update()

func update():
	var target_value = $"../..".current_health * 100 / $"../..".max_health
	
	var tween = create_tween()
	
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "value", target_value, 0.35)
