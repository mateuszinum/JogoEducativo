extends Area2D

@export var config: TesouroData

func _ready():
	# Se um recurso foi carregado, aplica a arte dele no Sprite2D
	if config and config.sprite_do_bau:
		$Sprite2D.texture = config.sprite_do_bau

func _on_body_entered(body):
	# 1. Verifica se quem pisou foi o Player (e não um inimigo, por exemplo)
	if body.is_in_group("Player"):
		
		# 2. Chama o gerenciador do mapa para criar um baú novo em outro lugar
		var mapa = get_tree().get_first_node_in_group("Mundo")
		if mapa:
			mapa.gerar_tesouro() 
			
		print("Pegou o tesouro!")
		
		# 3. Destrói o baú atual (ele desaparece da tela e da memória)
		queue_free()
