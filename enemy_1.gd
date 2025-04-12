extends CharacterBody2D

@onready var hitmarkSound = $hitmarkSound
var HP = 10
var SPEED = 350

func _physics_process(delta):
	var Player = get_parent().get_node("player")
	
	var direction = (Player.position - position).normalized()
	position += direction * SPEED * delta
	look_at(Player.position)
	move_and_slide()

func _on_hitbox_body_entered(body):
	if body.is_in_group("bullets"):
		if HP == 0:
			queue_free()
		else:
			HP -= 1	
			hitmarkSound.play()
