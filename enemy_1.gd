extends CharacterBody2D

@onready var hitmarkSound = $hitmarkSound
var nav_agent: NavigationAgent2D 

var HP = 3
var SPEED = 150.0
var knockback: Vector2 = Vector2.ZERO
var KNOCKBACK_DECAY: float = 600.0
var damage_to_player: int = 1
var can_damage: bool = true

@export_enum("default", "big", "shooter") var enemy_type: String = "default"

var BULLET = preload("res://bullet.tscn")
var shoot_timer: Timer

func _ready():
	nav_agent = get_node_or_null("NavigationAgent2D")
	if nav_agent:
		nav_agent.path_desired_distance = 4.0
		nav_agent.target_desired_distance = 4.0
	
	if $Hitbox:
		$Hitbox.body_entered.connect(_on_hitbox_body_entered)

	match enemy_type:
		"default":
			HP = 3
			SPEED = 150
		"big":
			HP = 12
			SPEED = 80
			scale = Vector2(2, 2)
		"shooter":
			HP = 6
			SPEED = 120
			_init_shooter()

func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("player")
	if not player: return

	var direction = Vector2.ZERO

	if nav_agent:
		nav_agent.target_position = player.global_position
		if not nav_agent.is_navigation_finished():
			direction = global_position.direction_to(nav_agent.get_next_path_position())
		else:
			direction = global_position.direction_to(player.global_position)
	else:
		direction = global_position.direction_to(player.global_position)

	velocity = direction * SPEED + knockback
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta)
	move_and_slide()

func take_hit(dmg, dir):
	HP -= dmg
	hitmarkSound.play()
	knockback = dir * 350.0
	if HP <= 0: die()

func die():
	var p = get_tree().get_first_node_in_group("player")
	if p: p.register_kill()
	queue_free()

func _on_hitbox_body_entered(body):
	if body.is_in_group("bullets"):
		var dmg = 1
		var dir = Vector2.ZERO
		if body.has_method("get_damage"): dmg = body.get_damage()
		if body.has_method("get_direction"): dir = body.get_direction()
		body.queue_free()
		take_hit(dmg, dir)
	elif body.is_in_group("player") and can_damage:
		body.take_damage(damage_to_player)
		start_damage_cooldown()

func start_damage_cooldown():
	can_damage = false
	await get_tree().create_timer(0.5).timeout
	can_damage = true

func _init_shooter():
	shoot_timer = Timer.new()
	shoot_timer.wait_time = 2.0
	shoot_timer.timeout.connect(_shoot)
	add_child(shoot_timer)
	shoot_timer.start()

func _shoot():
	var player = get_tree().get_first_node_in_group("player")
	if not player: return
	var b = BULLET.instantiate()
	b.global_position = global_position
	b.look_at(player.global_position)
	get_tree().current_scene.add_child(b)
