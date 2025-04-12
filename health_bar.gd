extends ProgressBar

@export var player: CharacterBody2D

func _ready():
	if player:
		player.health_changed.connect (update_health)
		
func update_health(new_health):
	value = new_health
