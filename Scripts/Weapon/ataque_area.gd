extends Weapon
class_name AtaqueEmArea

@export_group("Configurações de Área (AoE)")
@export var raio_explosao : float = 100.0
@export var tempo_visual : float = 1.0
@export var cor_explosao : Color = Color(1, 1, 1, 0.5)

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
		projectile.cor_explosao = cor_explosao # Agora passa a cor
		
	if "ataque_nome" in projectile:
		projectile.ataque_nome = nome
	
	projectile.look_at(target.global_position)
	source.get_parent().add_child(projectile)
	
func activate(source, target, scene_tree):
	shoot(source, target, scene_tree)
