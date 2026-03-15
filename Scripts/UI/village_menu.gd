extends Control

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	pass

func _on_start_game_pressed() -> void:
	var main_scene = get_node("/root/Jogo")
	if main_scene:
		main_scene.ir_para_arena()
