extends CharacterBody2D

@export var contact_damage: int = 1
@export var speed: float = 100.0
@export var max_health: float = 100.0
@export var knockback_force: float = 600.0


@export_category("elite")
@export_range(0.0, 1.0) var elite_chance : float = 1.0
@export var elite_health_multi = 2
@export var elite_damage_multi = 1.5
@export var elite_scale = 1.5
@export var is_elite = false

@export var stgn_ammo_scene : PackedScene
@export var ak_ammo_scene : PackedScene
@export var gun_ammo_scene : PackedScene
@export_category("drops")
@export var exp_gem_scene: PackedScene
@export var exp_amount: int = 10
@export_range(0.0, 1.0) var exp_drop_chance: float = 1.0

@export var potion_scenes : Array[PackedScene] = []
@export_range(0.0, 1.0) var potion_drop_chance: float = 0.2
@export var ak_drop_scene : PackedScene
@export var stgn_drop_scene : PackedScene
@export var drops_heal_poitons = false
@export var health_potion_scene : PackedScene
@export_range(0.0 , 1.0) var health_potion_drop_chance = 0.2
@export_range(0.0, 1.0) var gun_ammo_drop_chance :float = 1
@export_range(0.0, 1.0) var ak_ammo_drop_chance :float =0.2
@export_range(0.0, 1.0) var stgn_ammo_drop_chance:float = 0.2

var current_health: float 
var player_ref: Area2D = null
var player: CharacterBody2D = null
var knockback: Vector2 =Vector2.ZERO
var is_dying: bool = false
static var elite_spawned = 0
var elite_number = 0

@onready var hitbox: Area2D = $Hitbox
@onready var damage_timer: Timer = $DamageTimer


func make_elite():
	if elite_spawned >= 2:
		return
	
	elite_spawned += 1
	elite_number = elite_spawned
	is_elite =  true
	
	
	
	
	max_health *= elite_health_multi
	current_health = max_health
	contact_damage = int(contact_damage * elite_damage_multi)
	exp_amount *= 2
	
	scale *= elite_scale
	
	
	print("Elite enemy spawnedd")




	hitbox.area_entered.connect(_on_hitbox_area_entered)
	hitbox.area_exited.connect(_on_hitbox_area_exited)
	damage_timer.timeout.connect(_on_damage_timer_timeout)

func _on_hitbox_area_entered(area: Area2D) -> void:
	var target = area.owner
	if target and target.is_in_group("player"):
		player_ref = area
		deal_damage()
		damage_timer.start()

func _on_hitbox_area_exited(area: Area2D) -> void:
	if area == player_ref:
		player_ref = null
		damage_timer.stop()
func _ready() -> void:
	add_to_group("enemy")
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	
	
	print("Enemy spawned: ", name, " | Elite chance: ", elite_chance, " | Already spawned: ", elite_spawned)

	if elite_spawned < 2 and randf() <= elite_chance:
		make_elite()
	
	


func _on_damage_timer_timeout() -> void:
	deal_damage()

func deal_damage() -> void:
	if is_instance_valid(player_ref):
		var target = player_ref.owner
		if target and target.has_method("take_damage"):
			target.take_damage(contact_damage)
		

func _physics_process(delta: float) -> void:
	if is_dying:
		return
	
	
	if player:
		var kb_direction := global_position.direction_to(player.global_position)
		
		knockback = knockback.lerp(Vector2.ZERO, 10.0 * delta)
		
		velocity = (kb_direction * speed) + knockback
		move_and_slide()
		
		if kb_direction.x > 0:
			$AnimatedSprite2D.flip_h = false
		elif kb_direction.x < 0:
			$AnimatedSprite2D.flip_h = true

func take_damage(amount: float) -> void:
	current_health -= amount
	if current_health <= 0:
		die()
	else:
		$AnimatedSprite2D.play("hurt")
		await $AnimatedSprite2D.animation_finished
		$AnimatedSprite2D.play("default")
		


func apply_knockback(_source_position: Vector2) -> void:
	if is_instance_valid(player):
		var knockback_direction = player.global_position.direction_to(global_position)
		knockback = knockback_direction * knockback_force


func drop_heal_potion():
	if not drops_heal_poitons:
		return
	
	if health_potion_scene == null:
		return
	
	
	var chance = health_potion_drop_chance
	
	if is_instance_valid(player) and player.luck_activate:
		chance *= player.luck_multiplier
	
	chance = min(chance, 1)
	
	if randf()> chance:
		return
	
	
	var potion = health_potion_scene.instantiate()
	potion.global_position = global_position
	get_tree().current_scene.add_child(potion)




func drop_stgn_ammo():
	if stgn_ammo_scene == null:
		print("48748923")
		return
	
	var chance = stgn_ammo_drop_chance
	
	if is_instance_valid(player) and player.luck_activate:
		chance += player.luck_multiplier
	chance = min(chance, 1)
	if randf()> chance:
		return
	
	var ammo = stgn_ammo_scene.instantiate()
	ammo.global_position = global_position
	get_tree().current_scene.add_child(ammo)



func drop_ak_ammo():
	if ak_ammo_scene == null:
		print("akammoemptyscene")
		return
	
	var chance = ak_ammo_drop_chance
	
	if is_instance_valid(player) and player.luck_activate:
		chance *= player.luck_multiplier
	chance = min(chance, 1)
	if randf()> chance:
		return
	
	var ammo = ak_ammo_scene.instantiate()
	ammo.global_position = global_position
	get_tree().current_scene.add_child(ammo)
	
func drop_gun_ammo():
	if gun_ammo_scene == null:
		print("isempty")
		return
	
	var chance = gun_ammo_drop_chance
	
	if is_instance_valid(player) and player.luck_activate:
		chance *= player.luck_multiplier
		
	chance = min(chance, 1)
	if randf()> chance:
		return
			
	var ammo = gun_ammo_scene.instantiate()
	ammo.global_position = global_position
	get_tree().current_scene.add_child(ammo)

func drop_potion():
	if potion_scenes.is_empty():
		return
	
	var chance = potion_drop_chance
	
	print("Potion drop chance: ", chance * 100, "%")
	
	if is_instance_valid(player) and player.luck_activate:
		chance *= player.luck_multiplier
	
	chance = min(chance, 1)
	if randf() > chance:
		return
	
	var random_potion = potion_scenes.pick_random()
	
	if random_potion:
		var potion = random_potion.instantiate()
		potion.global_position = global_position
		get_tree().current_scene.add_child(potion)


func drop_ak():
	
	print("===== DROP AK CHECK =====")
	print("Enemy: ", name)
	print("is_elite: ", is_elite)
	print("ak_drop_scene: ", ak_drop_scene) 
	
	if not is_elite:
		return
	
	if ak_drop_scene == null:
		return
	
	var ak = ak_drop_scene.instantiate()
	ak.global_position = global_position
	get_tree().current_scene.add_child(ak)



func drop_stgn():
	if not is_elite:
		return
	
	if stgn_drop_scene == null:
		return
	
	var stgn = stgn_drop_scene.instantiate()
	stgn.global_position = global_position
	get_tree().current_scene.add_child(stgn)




func  drop_exp() -> void:
	if exp_gem_scene == null:
		return
	
	var chance = exp_drop_chance
	if is_instance_valid(player) and player.luck_activate:
		chance *= player.luck_multiplier
	chance = min(chance, 1.0)
	
	if randf() > chance:
		return
	
	var exp_gem = exp_gem_scene.instantiate()
	exp_gem.global_position = global_position
	
	if "exp_amount" in exp_gem:
		exp_gem.exp_amount = exp_amount
	
	get_tree().current_scene.add_child(exp_gem)

func die() -> void:
	if is_dying:
		return
	is_dying = true
	
	$Hitbox.monitoring = false
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	
	$AnimatedSprite2D.play("die")
	$death.play()
	
	
	await $AnimatedSprite2D.animation_finished
	
	drop_potion()
	drop_heal_potion()
	if elite_number == 1:
		drop_ak()
	elif elite_number == 2:
		drop_stgn()
	drop_gun_ammo()
	drop_ak_ammo()
	drop_stgn_ammo()
	drop_ak()
	
	drop_exp()
	
	queue_free()


		
#maybe if we improve this game we can add a lot of things fr fr f r fr 
