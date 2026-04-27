extends "res://enemy_1.gd"

func _ready():
	# Ghosts ignore walls!
	set_collision_mask_value(1, false) # Turn off collision with walls
	modulate = Color(0.5, 0.5, 1.0, 0.8) # Make it look ghostly
	SPEED = 100.0 # Slower but ignores walls
