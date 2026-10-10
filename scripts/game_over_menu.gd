extends CanvasLayer

@onready var restart_button: Button = %restart_button
@onready var quit_button: Button = %quit_button
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE)
	
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func  _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
