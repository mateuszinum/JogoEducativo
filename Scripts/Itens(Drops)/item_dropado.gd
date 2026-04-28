extends Area2D

var dados_do_item: ItemData
var player: Node2D

var velocidade_atual: float = 0.0
@export var aceleracao: float = 800.0
@export var velocidade_maxima: float = 450.0
var quantidade_neste_drop: int = 1

var estado: String = "explodindo"

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	
	var offset_aleatorio = Vector2(randf_range(-40, 40), randf_range(-40, 40))
	var alvo_explosao = global_position + offset_aleatorio
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "global_position", alvo_explosao, 0.4)
	tween.tween_callback(ativar_ima)

func ativar_ima() -> void:
	estado = "sugando"

func configurar(novo_item: ItemData, qtd: int) -> void:
	dados_do_item = novo_item
	quantidade_neste_drop = qtd 
	$Sprite2D.texture = dados_do_item.icone
	
	var tamanho_da_imagem = $Sprite2D.texture.get_size()
	var tamanho_maximo = 16.0 
	var maior_lado = max(tamanho_da_imagem.x, tamanho_da_imagem.y)
	
	var fator_de_escala = tamanho_maximo / maior_lado
	$Sprite2D.scale = Vector2(fator_de_escala, fator_de_escala)

func _physics_process(delta: float) -> void:
	if estado == "sugando" and player != null:
		velocidade_atual = move_toward(velocidade_atual, velocidade_maxima, aceleracao * delta)
		var direcao = global_position.direction_to(player.global_position)
		global_position += direcao * velocidade_atual * delta
		
		if global_position.distance_to(player.global_position) < 15.0:
			coletar_item()

func _on_body_entered(body: Node2D) -> void:
	if estado == "sugando" and body.is_in_group("Player"):
		coletar_item()

func coletar_item() -> void:
	@warning_ignore("narrowing_conversion")
	Inventario.adicionar_item(dados_do_item, quantidade_neste_drop * Atributos.coleta_multiplier) 
	
	if player != null and player.has_method("tocar_som_coleta"):
		player.tocar_som_coleta()
		
	queue_free()
