extends Weapon
class_name SingleShot

func shoot(source, target, _scene_tree):
	if target == null:
		return
		
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
	projectile.look_at(target.global_position)
	
	if "ataque_nome" in projectile:
		projectile.ataque_nome = nome
	
	source.get_parent().add_child(projectile)
	
func activate(source, target, scene_tree):
	shoot(source, target, scene_tree)
