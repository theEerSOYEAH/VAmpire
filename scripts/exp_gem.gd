extends Area2D

@export var exp_amount: int = 10
@export var base_magnet_speed = 300.0
@export var max_magnet_speed = 1200.0


var target_player: Node2D = null
var magnet_timer: float = 0.0
var is_collected: bool = false

func _ready() -> void:
	scale = Vector2.ZERO
	var spawn_tween = create_tween().set_parallel(true)
	spawn_tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT)

func  _physics_process(delta: float) -> void:
	if is_collected:
		return
		
	if is_instance_valid(target_player):
		magnet_timer += delta
		
		var current_speed = lerp(base_magnet_speed, max_magnet_speed, magnet_timer * 2.0)
		global_position = global_position.move_toward(target_player.global_position, current_speed * delta)
		
		rotation += delta * 12.0
		
	
func _on_body_entered(body: Node) -> void:
	if is_collected:
		return
	
	if body.is_in_group("player"):
		is_collected = true
		
		var pop_tween = create_tween().set_parallel(true)
		pop_tween.tween_property(self, "global_position", body.global_position, 0.12).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		pop_tween.tween_property(self, "scale", Vector2(1.6, 0.2), 0.12)
		
		await pop_tween.finished
		
		if body.has_method("add_xp"):
			body.add_xp(exp_amount)
			
		queue_free()


func _on_magnet_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and target_player == null:
		target_player = body
		
