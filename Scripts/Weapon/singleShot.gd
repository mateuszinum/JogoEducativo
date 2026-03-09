extends Weapon
class_name SingleShot

func shoot(source, target, scene_tree):
	if target == null:
		return
	
	var projectile = projectile_node.instantiate()
	
	projectile.position = source.position
	projectile.damage = damage
	projectile.speed = speed
	projectile.direction = (target.position - source.position).normalized()
	projectile.look_at(target.global_position) #os tiros vão mirar na direção do alvo mais proximo
	scene_tree.current_scene.add_child(projectile)
	
func activate(source, target, scene_tree):
	shoot(source, target, scene_tree)
