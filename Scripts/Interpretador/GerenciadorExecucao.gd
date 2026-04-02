extends Node

# Esta é a variável que o jogador pode dar UPGRADE!
# Quanto menor o número, mais rápido o código do jogador roda.
var tempo_tick: float = 1.0 

var interpretador_csharp: Node = null

# O C# vai se apresentar para este gerenciador quando o jogo começar
func registrar_interpretador(node: Node):
	interpretador_csharp = node

# O C# vai chamar esta função para realizar uma AÇÃO (Mover, Atacar, etc)
func executar_com_tick(alvo: Node, metodo: String, argumentos: Array):
	# 1. Executa a ação real no personagem (ex: player.mover("Cima"))
	alvo.callv(metodo, argumentos)
	
	# 2. Inicia o cronômetro do seu "Tick Rate" (A mágica do Upgrade acontece aqui)
	await get_tree().create_timer(tempo_tick).timeout
	
	# 3. O tempo passou! Avisa o C# para acordar e ler a próxima linha de código
	if interpretador_csharp != null and is_instance_valid(interpretador_csharp):
		interpretador_csharp.LiberarProximoComando()
