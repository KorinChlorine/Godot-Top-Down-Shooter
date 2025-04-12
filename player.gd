extends CharacterBody2D

var SPEED = 600
var BULLET_SPEED = 2500
var BULLET = preload("res://bullet.tscn")

@export var max_health: int = 3
@onready var shootSound = $gunSound
var health: int = max_health

signal health_changed(new_health)

func take_damage(amount):
	health -= amount
	health = max(health, 0)
	emit_signal("health_changed", health)
	if health == 0:
		kill()

func _physics_process(delta):
	velocity = Vector2()
	
	#input directions
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("right"):
		velocity.x += 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
		
	move_and_slide()
	look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("Fire"):
		fire()
		
	if Input.is_action_just_pressed("Fire"):
		shootSound.stream.loop = true
		shootSound.play()
	elif Input.is_action_just_released("Fire"):
		shootSound.stop()

func fire():
	var bullet_instance = BULLET.instantiate()
	bullet_instance.position = global_position
	bullet_instance.rotation_degrees = rotation_degrees
	bullet_instance.apply_impulse(Vector2(BULLET_SPEED, 0).rotated(rotation))
	bullet_instance.add_to_group("bullets")
	get_tree().get_root().call_deferred("add_child",bullet_instance)

func kill():
	get_tree().reload_current_scene()

func _on_hitbox_body_entered(body):
	if body.is_in_group("enemies"):
		take_damage(1)
		print("HP LOST")
		
				

			
		
		
