extends Node2D

@export var object_to_spawn: PackedScene

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		spawn_object()
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		shoot()

func spawn_object() -> void:
	var world_position: Vector2 = get_global_mouse_position()
	var obj = object_to_spawn.instantiate()
	obj.position = world_position
	add_child(obj)

func shoot() -> void:
	const BULLET = preload("res://Scenes/Projectiles/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	var world_position : Vector2 = get_global_mouse_position()
	new_bullet.global_position =  world_position
	add_child(new_bullet)
