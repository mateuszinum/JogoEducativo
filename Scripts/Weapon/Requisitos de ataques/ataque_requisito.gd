extends Resource
class_name AtaqueRequisito

# Função base que será sobrescrita por requisitos específicos
func verificar(_jogador: Node, _arma: Resource) -> bool:
	return true
