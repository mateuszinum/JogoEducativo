extends Control

@onready var container = $MarginContainer/HBoxContainer

func _ready() -> void:
	RecursosManager.recursos_alterados.connect(atualizar_tela)
	atualizar_tela()

func atualizar_tela() -> void:
	for filho in container.get_children():
		filho.queue_free()
		
	var recursos_atuais = RecursosManager.listarRecursos()
		
	for item in recursos_atuais:
		var quantidade = recursos_atuais[item]
		
		var slot = VBoxContainer.new()
		
		var icone = TextureRect.new()
		icone.texture = item.icone
		icone.custom_minimum_size = Vector2(20, 20)
		icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		var texto = Label.new()
		texto.text = str(quantidade)
		texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		slot.add_child(icone)
		slot.add_child(texto)
		
		container.add_child(slot)
