extends Node2D

var quant = 0

@export var object_to_spawn: PackedScene

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		spawn_object()

func spawn_object() -> void:
	var world_position: Vector2 = get_global_mouse_position()
	var obj = object_to_spawn.instantiate()
	obj.position = world_position
	add_child(obj)
	
	quant += 1
	print(quant)
