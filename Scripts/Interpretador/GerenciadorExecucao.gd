extends Node

var interpretador_csharp: Node = null

func registrar_interpretador(node: Node):
	interpretador_csharp = node

func executar_com_tick(alvo: Node, metodo: String, argumentos: Array):
	alvo.callv(metodo, argumentos)
	
	await get_tree().create_timer(Atributos.tempo_tick).timeout
	
	if is_instance_valid(interpretador_csharp):
		if interpretador_csharp.get("_execucaoAbortada") == false:
			interpretador_csharp.LiberarProximoComando()
