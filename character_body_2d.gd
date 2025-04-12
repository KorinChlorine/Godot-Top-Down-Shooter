extends CharacterBody2D


const SPEED = 600.0

func _physics_process(delta):
	velocity = Vector2()
	
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
		
