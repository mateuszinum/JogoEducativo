extends AtaqueRequisito
class_name SequenciaRequisito

# Agora aceita uma lista de Recursos do tipo Weapon em vez de Strings
@export var sequencia_obrigatoria: Array[Weapon] = []

func verificar(_jogador: Node, _arma: Resource) -> bool:
	var historico = HistoricoAcoes.ultimos_ataques
	var tamanho_req = sequencia_obrigatoria.size()
	
	if historico.size() < tamanho_req:
		return false
		
	var inicio_comparacao = historico.size() - tamanho_req
	for i in range(tamanho_req):
		# Pega a arma que arrastaste no Inspector
		var arma_exigida = sequencia_obrigatoria[i]
		
		# Verifica se o recurso é válido e compara o NOME da arma com o histórico
		if arma_exigida == null or historico[inicio_comparacao + i] != arma_exigida.nome:
			return false
			
	return true
