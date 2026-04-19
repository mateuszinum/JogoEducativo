extends AtaqueEmArea
class_name AtaqueAreaEscalonavel

@export_group("Combo Escalonável")
@export var magia_do_combo : Weapon
@export var raios_por_nivel : Array[float] = [30.0, 50.0, 70.0, 90.0, 125.0]

func shoot(source, target, scene_tree):
	if target == null or magia_do_combo == null:
		return
		
	var historico = HistoricoAcoes.ultimos_ataques
	var contador = 0
	
	# Conta de trás para frente quantos ataques iguais aconteceram em sequência
	for i in range(historico.size() - 1, -1, -1):
		if historico[i] == magia_do_combo.nome:
			contador += 1
		else:
			break # Interrompe a contagem se a sequência quebrar
			
	# Limita o nível ao tamanho da nossa array (Se o cap é 5, pega o índice 4)
	var max_niveis = raios_por_nivel.size()
	if max_niveis > 0:
		var nivel = clampi(contador, 1, max_niveis)
		
		# Atualiza a variável pai (raio_explosao) dinamicamente ANTES de gerar o projétil
		raio_explosao = raios_por_nivel[nivel - 1]
	
	# Chama a função shoot original do AtaqueEmArea para atirar de fato!
	super(source, target, scene_tree)
