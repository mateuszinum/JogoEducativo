extends PanelContainer

@export var weapon : Weapon:
	set(value):
		weapon = value
		$Cooldown.wait_time = value.cooldown

func _on_cooldown_timeout() -> void:
	pass
