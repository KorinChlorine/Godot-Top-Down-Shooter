extends ProgressBar

@export var player: CharacterBody2D

func _ready():
	# Wait for the player to be ready
	await get_tree().process_frame
	
	if player:
		# Use 'has_signal' as a safety check
		if player.has_signal("health_changed"):
			player.health_changed.connect(update_health)
			max_value = player.max_health
			value = player.health
		else:
			push_error("Player script is missing the 'health_changed' signal!")
	else:
		push_warning("HealthBar: No player assigned in Inspector.")

func update_health(new_health, new_max):
	max_value = new_max
	value = new_health
