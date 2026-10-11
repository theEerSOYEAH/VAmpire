extends Label

func _ready() -> void:
	# Set initial text
	update_display(GameManager.killed_enemies, GameManager.combo_count)
	
	# Listen to both signals from GameManager
	GameManager.kill_count_updated.connect(_on_kill_count_updated)
	GameManager.combo_updated.connect(_on_combo_updated)

func _on_kill_count_updated(new_count: int) -> void:
	update_display(new_count, GameManager.combo_count)

func _on_combo_updated(new_combo: int) -> void:
	update_display(GameManager.killed_enemies, new_combo)

func update_display(kills: int, combo: int) -> void:
	var display_text = "Kills: " + str(kills)
	
	# Only show the combo text if you have a streak going (2 or more kills)
	if combo > 1:
		display_text += " | Combo: x" + str(combo)
		
	text = display_text
