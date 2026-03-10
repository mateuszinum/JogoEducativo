extends Resource
class_name Enemy

@export var title : String
@export var animations : SpriteFrames 

@export var health : float
@export var damage : float
@export var speed : float = 10.0
@export var despawns : bool = true

@export_group("Audio")
@export var hurt_sound : AudioStream
@export var hurt_volume : float = 0.0
@export var pitch_min : float = 0.8
@export var pitch_max : float = 1.2
