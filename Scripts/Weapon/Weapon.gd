extends Resource
class_name Weapon

@export var damage : float
@export var cooldown : float
@export var speed : float
@export var knockback_multiplier : float = 1.0

@export var projectile_node : PackedScene = preload("res://Scenes/Weapons/Projectiles/arrow_shot.tscn")

func activate(_source, _target, _scene_tree):
	pass
