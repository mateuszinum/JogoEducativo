extends Control

# Puxando as referências da nova árvore de nós
@onready var fundo = $FundoInventario
@onready var titulo = $FundoInventario/Titulo
@onready var container_cinto = $FundoInventario/Cinto
@onready var container_mochila = $FundoInventario/Mochila

func _ready() -> void:
	if not Inventario.inventario_comprados_atualizado.is_connected(atualizar_slots_comprados):
		Inventario.inventario_comprados_atualizado.connect(atualizar_slots_comprados)
	
	atualizar_slots_comprados()

func atualizar_slots_comprados() -> void:
	for filho in container_cinto.get_children(): filho.queue_free()
	for filho in container_mochila.get_children(): filho.queue_free()
	
	if Inventario.inventario_ativo == Inventario.TipoInventario.CINTO:
		titulo.text = "CINTO"
		fundo.custom_minimum_size = Vector2(150, 100) 
		
		container_cinto.show()
		container_mochila.hide()
		_desenhar_slots(container_cinto)
		
	else:
		titulo.text = "MOCHILA"
		fundo.custom_minimum_size = Vector2(80, 250)
		
		container_mochila.show()
		container_cinto.hide()
		_desenhar_slots(container_mochila)


func _desenhar_slots(container_alvo: Control) -> void:
	var lista_atual = Inventario.get_lista_ativa()
	var capacidade = Inventario.get_capacidade_maxima()
	
	var ordem_dos_slots = range(capacidade) 
	
	if Inventario.inventario_ativo == Inventario.TipoInventario.MOCHILA:
		ordem_dos_slots = range(capacidade - 1, -1, -1)
	
	for i in ordem_dos_slots:
		
		var slot_fundo = Panel.new()
		slot_fundo.custom_minimum_size = Vector2(50, 50) 
		
		if i < lista_atual.size():
			var produto = lista_atual[i]
			
			if produto != null:
				var botao_item = TextureButton.new()
				
				botao_item.texture_normal = produto.icone
				botao_item.ignore_texture_size = true
				botao_item.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
				botao_item.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
				
				botao_item.pressed.connect(func(): Inventario.vender_item(i))
				
				slot_fundo.add_child(botao_item)
			
		container_alvo.add_child(slot_fundo)
