extends CanvasLayer

@onready var player = get_parent()

func _ready():
	%HealthBar.value = 100
	
	if player:
		player.health_changed.connect(_on_player_health_changed)
		
func _on_player_health_changed(new_health):
	%HealthBar.value = new_health
