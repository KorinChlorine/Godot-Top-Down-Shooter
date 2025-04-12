extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_delay: float = 0.5
@export var wave_duration: float = 30
@export var enemy_1: CharacterBody2D
@export var waveLabel: Label
var HP = 0
var SPEED = 0
var spawn_points = []
var current_wave = 1
var wave_timer: Timer
var spawn_timer: Timer

func update_label(new_text: String):
	if waveLabel:
		waveLabel.text = str(new_text)

func _ready():
	spawn_points = get_children()
	if spawn_points.is_empty():
		print("No spawn points!")
	
	wave_timer = Timer.new()
	wave_timer.wait_time = wave_duration
	wave_timer.one_shot = true
	wave_timer.connect("timeout", _on_wave_timeout)
	add_child(wave_timer)
	
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_delay
	spawn_timer.autostart = true
	spawn_timer.connect("timeout", spawn_enemy)
	add_child(spawn_timer)
	
	start_wave()

func start_wave():
	print("Wave", current_wave, "started!")
	wave_timer.start()
	spawn_timer.start() 

func spawn_enemy():
	if spawn_points.is_empty():
		return
	
	var enemy_instance = enemy_scene.instantiate()
	var spawn_location = spawn_points[randi() % spawn_points.size()]
	enemy_instance.position = spawn_location.position
	enemy_instance.add_to_group("enemies")
	get_tree().current_scene.add_child(enemy_instance)

	print("Enemy Spawned!")

func _on_wave_timeout():
	print("Wave", current_wave, "ended!")
	current_wave += 1
	update_label("Wave: " + str(current_wave))
	HP += 10
	SPEED += 5
	spawn_delay = max(spawn_delay - 0.2, 1)  
	spawn_timer.wait_time = spawn_delay  
	spawn_timer.start() 
	
	start_wave()
