extends PanelContainer

@export var weapon : Weapon:
	set(value):
		weapon = value
		$Cooldown.wait_time = value.cooldown

func _on_cooldown_timeout() -> void:
	if weapon:
		# Upgrades e level ups podem diminuir o cooldown da arma
		$Cooldown.wait_time = weapon.cooldown
		weapon.activate(owner, owner.nearest_enemy, get_tree())
