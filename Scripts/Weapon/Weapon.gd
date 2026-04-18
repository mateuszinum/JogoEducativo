extends Resource
class_name Weapon

@export var nome : String 

@export var damage : float
@export var speed : float
@export var knockback_multiplier : float = 1.0

@export_group("Custos")
@export var custo_do_ataque: Array[CustoAtaque] = []

# Weapon.gd (Adiciona estes campos)
@export_group("Requisitos")
@export var requisitos: Array[AtaqueRequisito] = []

@export_group("Audio")
@export var attack_sound : AudioStream
@export var attack_volume : float = 0.0
@export var hit_sound : AudioStream
@export var hit_volume : float = 0.0
@export var pitch_min : float = 0.8
@export var pitch_max : float = 1.2

@export_group("Audio Erro")
@export var som_erro : AudioStream
@export var volume_erro : float = 0.0

@export_group("Projectile")
@export var projectile_node : PackedScene = preload("res://Scenes/Weapons/EsferaAzul.tscn")

func activate(_source, _target, _scene_tree):
	pass
