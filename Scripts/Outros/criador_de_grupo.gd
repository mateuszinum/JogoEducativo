extends Node

@export var grupo: String = ""

func _ready() -> void:
	add_to_group(grupo) 
