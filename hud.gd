extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var gun_level_label = $GunLevelLabel
@onready var health_bar = $HealthBar

func _ready():
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.score_changed.connect(_on_score_changed)
		player.gun_level_changed.connect(_on_gun_level_changed)
		player.health_changed.connect(_on_health_changed)
		player.upgrade_choices.connect(_on_upgrade_choices)

		_on_score_changed(player.score)
		_on_gun_level_changed(player.gun_level)
		_on_health_changed(player.health, player.max_health)

func _on_score_changed(new_score):
	score_label.text = "Score: " + str(new_score)

func _on_gun_level_changed(new_level):
	gun_level_label.text = "Gun Lv: " + str(new_level)

func _on_health_changed(h, m):
	health_bar.max_value = m
	health_bar.value = h

func _on_upgrade_choices(choices):
	# For now auto-pick first choice
	var player = get_tree().get_first_node_in_group("player")
	if player and choices.size() > 0:
		player.apply_upgrade(choices[0])
