extends CharacterBody2D

signal health_changed(new_health, max_health)
signal score_changed(new_score)
signal gun_level_changed(new_level)
signal upgrade_choices(choices)
var base_upgrade_cost: int = 1000
var cost_multiplier: float = 1.5 # Each upgrade costs 50% more than the last

@export var max_health: int = 5
var health: int = max_health

@onready var shootSound = $gunSound
var BULLET = preload("res://bullet.tscn")
var iframes: float = 0.0
var IFRAME_DURATION: float = 0.6
var SPEED = 150.0
var kills: int = 0
var score: int = 0
var fire_timer: float = 0.0

var base_gun_stats = {
	"fire_rate": 5.0,
	"bullet_speed": 2000,
	"damage": 1,
	"count": 1,
	"spread": 0.0,
}

var chosen_upgrades: Array = []
var upgrade_options = [
	{ "name": "Rapid Fire", "fire_rate_bonus": 3.0 },
	{ "name": "Piercing Rounds", "damage_bonus": 1 },
	{ "name": "Multi-Shot", "count_bonus": 2, "spread_bonus": 10.0 },
	{ "name": "Sniper Precision", "bullet_speed_bonus": 500, "spread_bonus": -5.0 },
	{ "name": "Explosive Shot", "special": "explosive" },
]

var gun_level: int = 1
var upgrade_score_requirement: int = 1000

# === DASH SETTINGS ===
var DASH_SPEED = 1800.0
var DASH_DURATION = 0.15
var DASH_COOLDOWN = 0.8
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var dash_direction = Vector2.ZERO

func _ready():
	add_to_group("player")

func _physics_process(delta):
	# 1. Update Cooldowns
	if dash_cooldown_timer > 0: dash_cooldown_timer -= delta
	
	# 2. Define input_dir ONCE at the top
	var input_dir = Input.get_vector("left", "right", "up", "down")
	
	# 3. Dash Trigger
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and input_dir.length() > 0:
		is_dashing = true
		dash_timer = DASH_DURATION
		dash_cooldown_timer = DASH_COOLDOWN
		dash_direction = input_dir.normalized()
	
	# 4. Movement Logic
	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * DASH_SPEED
		if dash_timer <= 0: is_dashing = false
	else:
		velocity = input_dir * SPEED
		
	move_and_slide()
	look_at(get_global_mouse_position())

	# 5. Firing Logic
	fire_timer -= delta
	if Input.is_action_pressed("Fire") and fire_timer <= 0:
		fire()
	if iframes > 0:
		iframes -= delta
	velocity = input_dir * SPEED
	move_and_slide()
	look_at(get_global_mouse_position())

	fire_timer -= delta
	if Input.is_action_pressed("Fire") and fire_timer <= 0:
		fire()

	# Press E to trigger upgrade menu
	if Input.is_action_just_pressed("upgrade"):
		upgrade_gun()

func fire():
	var stats = get_current_stats()
	fire_timer = 1.0 / stats["fire_rate"]
	if shootSound:
		shootSound.stop()
		shootSound.play()
	
	for i in range(stats["count"]):
		var angle = rotation + deg_to_rad(lerp(-stats["spread"]/2.0, stats["spread"]/2.0, float(i)/max(1, stats["count"]-1)))
		var b = BULLET.instantiate()
		b.global_position = global_position
		b.rotation = angle
		b.speed = stats["bullet_speed"]
		b.damage = stats["damage"]
		if stats.has("special") and stats["special"] == "explosive":
			b.is_explosive = true
		get_tree().current_scene.add_child(b)

func get_current_stats() -> Dictionary:
	var stats = base_gun_stats.duplicate()
	for upgrade in chosen_upgrades:
		if upgrade.has("fire_rate_bonus"): stats["fire_rate"] += upgrade["fire_rate_bonus"]
		if upgrade.has("damage_bonus"): stats["damage"] += upgrade["damage_bonus"]
		if upgrade.has("count_bonus"): stats["count"] += upgrade["count_bonus"]
		if upgrade.has("spread_bonus"): stats["spread"] += upgrade["spread_bonus"]
		if upgrade.has("bullet_speed_bonus"): stats["bullet_speed"] += upgrade["bullet_speed_bonus"]
		if upgrade.has("special"): stats["special"] = upgrade["special"]
	return stats

func take_damage(amount: int):
	# NOW THIS FUNCTION WILL WORK
	if iframes > 0: return 
	
	health -= amount
	emit_signal("health_changed", health, max_health)
	iframes = IFRAME_DURATION 
	
	if health <= 0:
		get_tree().reload_current_scene()

func heal(amount: int):
	health = clamp(health + amount, 0, max_health)
	emit_signal("health_changed", health, max_health)

func die():
	print("Player died!")

func register_kill():
	kills += 1
	score += 10
	emit_signal("score_changed", score)
	
	# Check if player has enough score to afford the NEXT upgrade
	if score >= upgrade_score_requirement:
		upgrade_gun()
		

func upgrade_gun():
	# 1. Logic to show the menu (handled by your UI)
	var pool = upgrade_options.duplicate()
	pool.shuffle()
	var choices: Array = []
	for i in range(min(3, pool.size())):
		choices.append(pool[i])
		
	emit_signal("upgrade_choices", choices)
	
	# 2. Increase the cost for the NEXT time
	# This makes it harder each time (e.g., 1000 -> 1500 -> 2250 -> 3375)
	upgrade_score_requirement = int(upgrade_score_requirement * cost_multiplier)
	print("Next upgrade will cost: ", upgrade_score_requirement)

func apply_upgrade(choice: Dictionary):
	print("Applying upgrade:", choice)
	chosen_upgrades.append(choice)
	gun_level = chosen_upgrades.size()
	emit_signal("gun_level_changed", gun_level)
