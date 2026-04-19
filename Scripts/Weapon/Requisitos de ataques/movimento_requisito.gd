extends AtaqueRequisito
class_name MovimentoRequisito

@export var sequencia_obrigatoria: Array[String] = []

func verificar(_jogador: Node, _arma: Resource) -> bool:
	var historico = HistoricoAcoes.ultimos_movimentos
	var tamanho_req = sequencia_obrigatoria.size()
	
	if historico.size() < tamanho_req:
		return false
		
	var inicio_comparacao = historico.size() - tamanho_req
	for i in range(tamanho_req):
		var dir_exigida = sequencia_obrigatoria[i].to_lower().strip_edges()
		if historico[inicio_comparacao + i] != dir_exigida:
			return false
			
	return true
