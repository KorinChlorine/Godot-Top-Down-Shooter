extends Area2D

var speed: float = 2000.0
var damage: int = 1
var is_explosive: bool = false

func _ready():
	body_entered.connect(_on_body)
	get_tree().create_timer(2.0).timeout.connect(queue_free)

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_body(body):
	if body.has_method("take_hit"):
		body.take_hit(damage, transform.x)
	if is_explosive:
		explode()
	if not body.is_in_group("bullets"):
		queue_free()

func explode():
	print("Explosion triggered!")
	# Example explosion effect: damage nearby enemies
	var area = Area2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 100
	var collision = CollisionShape2D.new()
	collision.shape = shape
	area.add_child(collision)
	area.global_position = global_position
	get_tree().current_scene.add_child(area)
	for enemy in area.get_overlapping_bodies():
		if enemy.has_method("take_hit"):
			enemy.take_hit(damage)
	area.queue_free()
