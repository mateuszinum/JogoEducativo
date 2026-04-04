extends Button

@export var produto: ProdutoLoja
@onready var tooltip = %TooltipBox

var nivel_atual: int = 0

func _ready() -> void:
	tooltip.hide()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	if produto:
		# Define onde a contagem de nível começa baseado no tipo
		if produto.tipo == ProdutoLoja.TipoProduto.UPGRADE:
			nivel_atual = 1 # O personagem já começa com o Atributo Base
		else:
			nivel_atual = 0 # Itens, Funções ou Magias novas começam no 0
			
		preparar_bolinhas()
		atualizar_visual()

func _pressed() -> void:
	# SIMULAÇÃO DE CLIQUE: Avança os níveis corretamente para o teste visual
	match produto.tipo:
		ProdutoLoja.TipoProduto.ITEM_UNICO:
			pass # Compra infinita, não muda de nível
			
		ProdutoLoja.TipoProduto.DESBLOQUEIO_UNICO:
			if nivel_atual == 0: nivel_atual = 1
			
		ProdutoLoja.TipoProduto.UPGRADE:
			if nivel_atual < produto.niveis.size() + 1: nivel_atual += 1
			
		ProdutoLoja.TipoProduto.DESBLOQUEIO_PROGRESSIVO:
			if nivel_atual < produto.niveis.size(): nivel_atual += 1
			
	atualizar_visual()

# --- FORMATAÇÃO VISUAL ---
func atualizar_visual() -> void:
	if %IconeProduto: %IconeProduto.texture = produto.icone
	if %TooltipNome: %TooltipNome.text = produto.nome
		
	# Atualiza a cor das bolinhas (só aciona se for um tipo com progressão)
	if produto.tipo == ProdutoLoja.TipoProduto.UPGRADE or produto.tipo == ProdutoLoja.TipoProduto.DESBLOQUEIO_PROGRESSIVO:
		for i in range(%ContainerBolinhas.get_child_count()):
			var bolinha = %ContainerBolinhas.get_child(i)
			if i < nivel_atual: bolinha.color = Color.GREEN
			else: bolinha.color = Color.DARK_GRAY
				
	carregar_dados_do_tooltip()

func carregar_dados_do_tooltip() -> void:
	var texto_final: String = ""
	var item_custo: ItemData = null
	var qtd_custo: int = 0
	var mostrar_custo: bool = true
	
	match produto.tipo:
		ProdutoLoja.TipoProduto.ITEM_UNICO:
			texto_final = produto.descricao_simples
			item_custo = produto.custo_item_simples
			qtd_custo = produto.custo_quantidade_simples
			
		ProdutoLoja.TipoProduto.DESBLOQUEIO_UNICO:
			if nivel_atual == 0:
				texto_final = produto.descricao_simples
				item_custo = produto.custo_item_simples
				qtd_custo = produto.custo_quantidade_simples
			else:
				texto_final = produto.descricao_simples + "\n\n(JÁ DESBLOQUEADO)"
				mostrar_custo = false
				
		ProdutoLoja.TipoProduto.UPGRADE:
			var max_niveis = produto.niveis.size() + 1
			if nivel_atual == 1:
				texto_final = produto.descricao_atual_base
				if produto.descricao_upgrade_base != "":
					texto_final += "\n\n" + produto.descricao_upgrade_base
			else:
				var index = nivel_atual - 2
				texto_final = produto.niveis[index].descricao_atual
				if produto.niveis[index].descricao_upgrade != "":
					texto_final += "\n\n" + produto.niveis[index].descricao_upgrade
				
			if nivel_atual < max_niveis:
				var index_proximo = nivel_atual - 1
				item_custo = produto.niveis[index_proximo].custo_item
				qtd_custo = produto.niveis[index_proximo].custo_quantidade
			else:
				mostrar_custo = false
				
		ProdutoLoja.TipoProduto.DESBLOQUEIO_PROGRESSIVO:
			var max_niveis = produto.niveis.size()
			if nivel_atual == 0:
				texto_final = produto.descricao_bloqueada
			else:
				var index = nivel_atual - 1
				texto_final = produto.niveis[index].descricao_atual
				if produto.niveis[index].descricao_upgrade != "":
					texto_final += "\n\n" + produto.niveis[index].descricao_upgrade
				
			if nivel_atual < max_niveis:
				var index_proximo = nivel_atual
				item_custo = produto.niveis[index_proximo].custo_item
				qtd_custo = produto.niveis[index_proximo].custo_quantidade
			else:
				mostrar_custo = false

	# VERIFICAÇÃO FINAL: Se o desenvolvedor não colocou nenhum item de custo, não mostre a área.
	if item_custo == null:
		mostrar_custo = false

	# Aplica na UI
	if %TooltipDescricao: %TooltipDescricao.text = texto_final
	
	if mostrar_custo:
		%AreaDoPreco.show()
		if %TooltipCustoValor: %TooltipCustoValor.text = str(qtd_custo)
		if %TooltipCustoIcone and item_custo: %TooltipCustoIcone.texture = item_custo.icone
	else:
		%AreaDoPreco.hide() # O VBoxContainer vai colapsar este espaço automaticamente
		
		%TooltipBox.size = Vector2.ZERO

# --- CONSTRUÇÃO DINÂMICA DAS BOLINHAS ---
func preparar_bolinhas() -> void:
	for child in %ContainerBolinhas.get_children():
		child.queue_free()
		
	var qtd_bolinhas = 0
	if produto.tipo == ProdutoLoja.TipoProduto.UPGRADE:
		qtd_bolinhas = produto.niveis.size() + 1
	elif produto.tipo == ProdutoLoja.TipoProduto.DESBLOQUEIO_PROGRESSIVO:
		qtd_bolinhas = produto.niveis.size()
		
	for i in range(qtd_bolinhas):
		var bolinha = ColorRect.new()
		bolinha.custom_minimum_size = Vector2(8, 8)
		var estilo = StyleBoxFlat.new()
		estilo.corner_radius_top_left = 4
		estilo.corner_radius_top_right = 4
		estilo.corner_radius_bottom_left = 4
		estilo.corner_radius_bottom_right = 4
		bolinha.add_theme_stylebox_override("panel", estilo)
		%ContainerBolinhas.add_child(bolinha)

func _process(_delta: float) -> void:
	if tooltip.visible: tooltip.global_position = get_global_mouse_position() + Vector2(20, 25)

func _on_mouse_entered() -> void: tooltip.show()
func _on_mouse_exited() -> void: tooltip.hide()
