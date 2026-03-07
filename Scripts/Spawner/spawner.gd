extends Node2D

@export var player : CharacterBody2D
@export var enemy : PackedScene
@export var max_enemies : int
@export var enemy_types : Array[Enemy]

# Distancia que o inimigo irá spawnar do player
var distance : float = 400
var can_spawn : bool = true

#func _physics_process(_delta: float) -> void:
	#if get_tree().get_node_count_in_group("Enemy") < max_enemies:
		#can_spawn = true
	#else:
		#can_spawn = false

func spawn(pos : Vector2):
	#if not can_spawn:
		#return
	if get_tree().get_node_count_in_group("Enemy") >= max_enemies:
		return

	var enemy_instance = enemy.instantiate()
	
	#enemy_instance.type = enemy_types[min(minute, enemy_types.size()-1)]
	enemy_instance.type = enemy_types.pick_random()
	enemy_instance.position = pos
	enemy_instance.player_reference = player
	
	get_tree().current_scene.add_child(enemy_instance)

func get_random_position() -> Vector2:
	return player.position + distance * Vector2.RIGHT.rotated(randf_range(0, 2 * PI))

func amount(number : int = 1):
	for i in range(number):
		spawn(get_random_position())

func _on_timer_timeout() -> void:
	seconds += 1
	amount(seconds % 10)

func _on_pattern_timeout() -> void:
	for i in range(15):
		spawn(get_random_position())

# Timer
var minute : int:
	set(value):
		minute = value
		%Minute.text = str(value)

var seconds : int:
	set(value):
		seconds = value
		
		# Normal é colocar segundos como 60
		if seconds >= 60:
			seconds -= 60
			minute += 1
		%Seconds.text = str(seconds).lpad(2, '0')
