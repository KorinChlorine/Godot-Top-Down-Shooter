extends Node2D

var enemy_scenes: Dictionary = {
	"basic": preload("res://enemy_1.tscn"),
	"big": preload("res://enemy_2.tscn")
	# You can add more later, e.g. shooter, fast, etc.
}

@export var waveLabel: Label
@export var wave_announce_label: Label

var current_wave: int = 1
var wave_duration: float = 25.0
var wave_active: bool = false
var spawn_timer: Timer

func _ready():
	_start_wave()

func _start_wave():
	wave_active = true
	waveLabel.text = "Wave: %d" % current_wave
	if wave_announce_label:
		wave_announce_label.text = "Wave %d Starting!" % current_wave
		await get_tree().create_timer(2.0).timeout
		wave_announce_label.text = ""

	spawn_timer = Timer.new()
	spawn_timer.wait_time = max(0.2, 0.6 * pow(0.95, current_wave - 1))
	spawn_timer.timeout.connect(_spawn_enemy)
	add_child(spawn_timer)
	spawn_timer.start()
	
	await get_tree().create_timer(wave_duration).timeout
	_wave_complete()

func _spawn_enemy():
	if not wave_active: return
	var player = get_tree().get_first_node_in_group("player")
	if not is_instance_valid(player): return

	# Scale spawn count per wave
	var spawn_count = 2 + int(current_wave * 0.7)

	for i in range(spawn_count):
		var enemy_type = _pick_enemy_type()
		var enemy_scene = enemy_scenes.get(enemy_type, null)
		if enemy_scene == null: continue

		var enemy = enemy_scene.instantiate()
		var pos = _find_valid_spawn_position(player)
		if pos == Vector2.ZERO: continue

		enemy.global_position = pos
		enemy.HP = int(enemy.HP * pow(1.2, current_wave - 1))
		enemy.SPEED += current_wave * 3

		add_child(enemy)

func _pick_enemy_type() -> String:
	if current_wave < 3:
		return "basic"
	else:
		return ["basic", "big"].pick_random()

func _find_valid_spawn_position(player) -> Vector2:
	for i in range(20):
		var angle = randf() * TAU
		var dist = randf_range(600, 900)
		var pos = player.global_position + Vector2(cos(angle), sin(angle)) * dist
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = pos
		query.collision_mask = 1
		if space_state.intersect_point(query).is_empty():
			return pos
	return Vector2.ZERO

func _wave_complete():
	wave_active = false
	if is_instance_valid(spawn_timer): spawn_timer.queue_free()
	if wave_announce_label: wave_announce_label.text = "Wave Clear!"
	current_wave += 1
	await get_tree().create_timer(3.0).timeout
	_start_wave()
