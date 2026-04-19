@tool
extends Weapon
class_name AtaqueEmArea

@export_group("Configurações de Área (AoE)")
@export var raio_explosao : float = 100.0
@export var tempo_visual : float = 1.0

var usar_textura_para_explosao : bool = false:
	set(value):
		usar_textura_para_explosao = value
		notify_property_list_changed()

var cor_explosao : Color = Color(1.0, 1.0, 1.0, 0.5)
var animacao_explosao : SpriteFrames

var usar_luz_na_explosao : bool = false:
	set(value):
		usar_luz_na_explosao = value
		notify_property_list_changed()

var luz_cor : Color = Color(1, 0.8, 0.4, 1)
var luz_energia : float = 1.5
var luz_tempo_fade : float = 0.5
var luz_textura : Texture2D
var luz_multiplicador_area : float = 1.0

func _get_property_list() -> Array:
	var properties = []
	
	properties.append({"name": "Visual da Explosão", "type": TYPE_NIL, "usage": PROPERTY_USAGE_GROUP, "hint_string": "Visual da Explosão"})
	properties.append({"name": "usar_textura_para_explosao", "type": TYPE_BOOL, "usage": PROPERTY_USAGE_DEFAULT})
	
	if usar_textura_para_explosao:
		properties.append({"name": "animacao_explosao", "type": TYPE_OBJECT, "hint": PROPERTY_HINT_RESOURCE_TYPE, "hint_string": "SpriteFrames", "usage": PROPERTY_USAGE_DEFAULT})
	else:
		properties.append({"name": "cor_explosao", "type": TYPE_COLOR, "usage": PROPERTY_USAGE_DEFAULT})
		
	properties.append({"name": "Iluminação da Explosão", "type": TYPE_NIL, "usage": PROPERTY_USAGE_GROUP, "hint_string": "Iluminação da Explosão"})
	properties.append({"name": "usar_luz_na_explosao", "type": TYPE_BOOL, "usage": PROPERTY_USAGE_DEFAULT})
	
	if usar_luz_na_explosao:
		properties.append({"name": "luz_cor", "type": TYPE_COLOR, "usage": PROPERTY_USAGE_DEFAULT})
		properties.append({"name": "luz_energia", "type": TYPE_FLOAT, "usage": PROPERTY_USAGE_DEFAULT})
		properties.append({"name": "luz_tempo_fade", "type": TYPE_FLOAT, "usage": PROPERTY_USAGE_DEFAULT})
		properties.append({"name": "luz_textura", "type": TYPE_OBJECT, "hint": PROPERTY_HINT_RESOURCE_TYPE, "hint_string": "Texture2D", "usage": PROPERTY_USAGE_DEFAULT})
		properties.append({"name": "luz_multiplicador_area", "type": TYPE_FLOAT, "usage": PROPERTY_USAGE_DEFAULT})
		
	return properties

func shoot(source, target, scene_tree):
	if target == null: return
		
	if attack_sound != null:
		var audio = AudioStreamPlayer2D.new()
		audio.stream = attack_sound
		audio.volume_db = attack_volume
		audio.bus = "SFX"
		audio.global_position = source.global_position
		audio.pitch_scale = randf_range(pitch_min, pitch_max)
		source.get_parent().add_child(audio)
		audio.play()
		audio.finished.connect(audio.queue_free)
	
	var projectile = projectile_node.instantiate()
	projectile.position = source.position
	projectile.damage = damage
	projectile.speed = speed
	projectile.knockback_multiplier = knockback_multiplier
	projectile.hit_sound = hit_sound
	projectile.hit_volume = hit_volume
	projectile.pitch_min = pitch_min
	projectile.pitch_max = pitch_max
	projectile.direction = (target.position - source.position).normalized()
	
	if "raio_explosao" in projectile:
		projectile.raio_explosao = raio_explosao
		projectile.tempo_visual = tempo_visual
		projectile.usar_textura_para_explosao = usar_textura_para_explosao
		projectile.cor_explosao = cor_explosao
		projectile.animacao_explosao = animacao_explosao
		projectile.usar_luz_na_explosao = usar_luz_na_explosao
		projectile.luz_cor = luz_cor
		projectile.luz_energia = luz_energia
		projectile.luz_tempo_fade = luz_tempo_fade
		projectile.luz_textura = luz_textura
		projectile.luz_multiplicador_area = luz_multiplicador_area
		
	if "ataque_nome" in projectile:
		projectile.ataque_nome = nome
	
	projectile.look_at(target.global_position)
	source.get_parent().add_child(projectile)
	
func activate(source, target, scene_tree):
	shoot(source, target, scene_tree)
