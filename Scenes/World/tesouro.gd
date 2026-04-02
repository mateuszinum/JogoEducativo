extends Area2D

# Essa função é criada automaticamente quando você conecta o sinal pelo editor.
# A variável 'body' é quem acabou de pisar no baú.
func _on_body_entered(body):
	print("ENTROU AQUI")
	# 1. Verifica se quem pisou foi o Player (e não um inimigo, por exemplo)
	if body.is_in_group("Player"):
		
		# 2. Chama o gerenciador do mapa para criar um baú novo em outro lugar
		var mapa = get_tree().get_first_node_in_group("Mundo")
		if mapa:
			# Importante: você vai precisar criar essa função gerar_tesouro() no script do mapa
			mapa.gerar_tesouro() 
			
		# 3. Opcional: Tocar um som, rodar uma animação ou dar pontos pro jogador aqui
		print("Pegou o tesouro!")
		
		# 4. Destrói o baú atual (ele desaparece da tela e da memória)
		queue_free()
