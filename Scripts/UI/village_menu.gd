extends Control

@onready var musica_vilarejo = $MusicaVilarejo

func _ready() -> void:
	if musica_vilarejo and not musica_vilarejo.playing:
		musica_vilarejo.volume_db = 0.0 
		musica_vilarejo.play()

func _on_start_game_pressed() -> void:
	# Apenas avisa a cena mestre. O jogo.gd cuida do visual e sonoro!
	var main_scene = get_node_or_null("/root/Jogo")
	if main_scene and main_scene.has_method("ir_para_arena"):
		main_scene.ir_para_arena()
