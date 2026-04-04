extends CanvasLayer

@onready var container = $MarginContainer/HBoxContainer

func _ready() -> void:
	# Fica "escutando" o sinal do nosso Autoload
	Inventario.inventario_atualizado.connect(atualizar_tela)
	atualizar_tela()

func atualizar_tela() -> void:
	# 1. Limpa a UI antiga inteira
	for filho in container.get_children():
		filho.queue_free()
		
	# 2. Reconstrói a UI lendo o Dicionário atualizado
	for item in Inventario.itens_coletados:
		var quantidade = Inventario.itens_coletados[item]
		
		# Cria um mini-container vertical (VBoxContainer) para cada item
		var slot = VBoxContainer.new()
		
		# Cria a imagem (TextureRect)
		var icone = TextureRect.new()
		icone.texture = item.icone
		icone.custom_minimum_size = Vector2(32, 32)
		icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		# Cria o texto com a quantidade (Label)
		var texto = Label.new()
		texto.text = str(quantidade)
		texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		# Opcional: Aqui você pode colocar uma fonte bonitinha no Label!
		
		# Monta o "lego"
		slot.add_child(icone)
		slot.add_child(texto)
		
		# Joga na tela!
		container.add_child(slot)
