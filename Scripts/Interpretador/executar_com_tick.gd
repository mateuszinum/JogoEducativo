extends Node

func mover(direcao: String):
	await GerenciadorExecucao.executar_com_tick(FuncoesNativas, "mover", [direcao])

func atacar(alvo: String, tipo: String):
	await GerenciadorExecucao.executar_com_tick(FuncoesNativas, "atacar", [alvo, tipo])

func escapar():
	await GerenciadorExecucao.executar_com_tick(FuncoesNativas, "escapar", [])

func usar_item_cinto(indice: int):
	await GerenciadorExecucao.executar_com_tick(FuncoesNativas, "usar_item_cinto", [indice])

func usar_item_mochila():
	await GerenciadorExecucao.executar_com_tick(FuncoesNativas, "usar_item_mochila", [])

func comprar(item: String):
	await GerenciadorExecucao.executar_com_tick(FuncoesNativas, "comprar", [item])

func vender_tudo():
	await GerenciadorExecucao.executar_com_tick(FuncoesNativas, "venderTudo", [])

func entrar_arena(arena: String):
	await GerenciadorExecucao.executar_com_tick(FuncoesNativas, "arena", [arena])

# SENSORES (Chamada direta, pois não precisam de delay)
func inimigo_mais_proximo() -> String:
	return FuncoesNativas.inimigoMaisProximo()

func pode_mover(direcao: String) -> bool:
	return FuncoesNativas.podeMover(direcao)

func get_vida_atual() -> int:
	return FuncoesNativas.getVidaAtual()

func get_posicao_player_x() -> int:
	return FuncoesNativas.posicaoX()

func get_posicao_player_y() -> int:
	return FuncoesNativas.posicaoY()

func get_posicao_tesouro_x() -> int:
	return FuncoesNativas.tesouroX()

func get_posicao_tesouro_y() -> int:
	return FuncoesNativas.tesouroY()

func escanear_area() -> Array:
	return FuncoesNativas.escanearArea()

func escreva(texto: String):
	FuncoesNativas.escreva(texto)
