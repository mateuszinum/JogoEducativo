extends Area2D

var dados_do_item: ItemData
var player: Node2D

# Variáveis para o Efeito Ímã
var velocidade_atual: float = 0.0
@export var aceleracao: float = 800.0
@export var velocidade_maxima: float = 450.0

var quantidade_neste_drop: int = 1

func _ready() -> void:
	# Assim que o item nasce no mundo, ele procura quem é o Player
	player = get_tree().get_first_node_in_group("Player")

func configurar(novo_item: ItemData, qtd: int) -> void:
	dados_do_item = novo_item
	quantidade_neste_drop = qtd # Salva o número sorteado!
	$Sprite2D.texture = dados_do_item.icone
	
	# Pega o tamanho real da imagem em pixels
	var tamanho_da_imagem = $Sprite2D.texture.get_size()
	
	# Define qual é o tamanho máximo (em pixels) que o item pode ter na tela
	var tamanho_maximo = 16.0 # Mude esse número para o tamanho que ficar melhor no seu jogo!
	
	# Descobre qual lado da imagem é maior (largura ou altura) para não distorcer
	var maior_lado = max(tamanho_da_imagem.x, tamanho_da_imagem.y)
	
	# Calcula a proporção e aplica APENAS na imagem (não mexe na área de colisão)
	var fator_de_escala = tamanho_maximo / maior_lado
	$Sprite2D.scale = Vector2(fator_de_escala, fator_de_escala)

# O _physics_process roda 60 vezes por segundo para atualizar a física
func _physics_process(delta: float) -> void:
	if player != null:
		velocidade_atual = move_toward(velocidade_atual, velocidade_maxima, aceleracao * delta)
		var direcao = global_position.direction_to(player.global_position)
		global_position += direcao * velocidade_atual * delta
		
		# --- TRUQUE ANTI-BUG: Força a coleta se chegar muito perto ---
		if global_position.distance_to(player.global_position) < 15.0:
			coletar_item()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		coletar_item()

func coletar_item() -> void:
	# Envia para o inventário o item E a quantidade sorteada!
	Inventario.adicionar_item(dados_do_item, quantidade_neste_drop) 
	queue_free()
