extends RigidBody2D

@export var lifetime: float = 3.0
# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
