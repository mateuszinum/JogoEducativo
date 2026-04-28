extends Node

var interpretador_csharp: Node = null

# ==========================================
# CONFIGURAÇÃO DE DELAYS 

const TEMPO_FALHA = 1.0
# ==========================================

# 1. AÇÕES VINCULADAS À AGILIDADE (Multiplicam o tempo_tick)
const MULTIPLICADOR_TICK = {
	"atacar": 1.0,
	"mover": 0.1,
	"usar_item_cinto": 0.1,
	"usar_item_mochila": 0.1,
	"colocar_item_cinto": 0.1,
	"colocar_item_mochila": 0.1,
	"comprar": 0.2,
	"venderTudo": 0.2
}

# 2. COOLDOWNS MÍNIMOS (Multiplicam o tempo_tick)
# Impede que a mesma ação seja metralhada seguidamente.
const COOLDOWNS_MINIMOS = {
	"mover": 1.0
}

# 3. AÇÕES DE TEMPO FIXO (Ignoram os atributos do jogador, em Segundos)
const TEMPO_FIXO_SEGUNDOS = {
	"escapar": 1, 
	"arena": 1    
}

var _ultimo_uso_da_acao: Dictionary = {}

func registrar_interpretador(node: Node):
	interpretador_csharp = node
	_ultimo_uso_da_acao.clear()

func executar_com_tick(alvo: Node, metodo: String, argumentos: Array):
	var tempo_atual_msec = Time.get_ticks_msec()
	
	var tempo_espera_pre: float = 0.0
	var tempo_espera_pos: float = 0.0
	
	if TEMPO_FIXO_SEGUNDOS.has(metodo):
		tempo_espera_pos = TEMPO_FIXO_SEGUNDOS[metodo]
	else:
		var peso = MULTIPLICADOR_TICK.get(metodo, 1.0)
		tempo_espera_pos = Atributos.tempo_tick * peso
		
		if COOLDOWNS_MINIMOS.has(metodo):
			var cooldown_exigido = Atributos.tempo_tick * COOLDOWNS_MINIMOS[metodo]
			
			if _ultimo_uso_da_acao.has(metodo):
				var tempo_passado = (tempo_atual_msec - _ultimo_uso_da_acao[metodo]) / 1000.0
				if tempo_passado < cooldown_exigido:
					tempo_espera_pre = cooldown_exigido - tempo_passado
					
			_ultimo_uso_da_acao[metodo] = tempo_atual_msec + int(tempo_espera_pre * 1000)
		else:
			_ultimo_uso_da_acao[metodo] = tempo_atual_msec

	if tempo_espera_pre > 0.0:
		await get_tree().create_timer(tempo_espera_pre).timeout
		
	var sucesso = alvo.callv(metodo, argumentos)
	
	if typeof(sucesso) == TYPE_BOOL and sucesso == false:
		tempo_espera_pos = TEMPO_FALHA * Atributos.tempo_tick
		
		if _ultimo_uso_da_acao.has(metodo):
			_ultimo_uso_da_acao.erase(metodo)
	
	if tempo_espera_pos > 0.0:
		await get_tree().create_timer(tempo_espera_pos).timeout
	
	if is_instance_valid(interpretador_csharp):
		if interpretador_csharp.get("_execucaoAbortada") == false:
			interpretador_csharp.LiberarProximoComando()
