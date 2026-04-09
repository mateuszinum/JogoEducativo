extends Button

@export var produto: ProdutoLoja
@onready var tooltip = %TooltipBox

# --- VARIÁVEIS DE VISUAL E ANIMAÇÃO ---
@export_group("Animação e Visual")
@export var visual_animado: Control 
@export var fundo_colorido: CanvasItem 

@export var escala_normal: Vector2 = Vector2(1.0, 1.0) 
@export var escala_hover: Vector2 = Vector2(1.1, 1.1) 
@export var escala_clique: Vector2 = Vector2(0.9, 0.9) 
@export var tempo_transicao: float = 0.1 

@export_group("Cores de Estado")
@export var cor_desbloqueado: Color = Color.WHITE
@export var cor_disponivel: Color = Color(0.25, 0.25, 0.25, 1.0) 
@export var cor_bloqueado: Color = Color(0.6, 0.15, 0.15, 1.0) 
@export var cor_erro_piscar: Color = Color(1.0, 0.2, 0.2, 1.0) 
# NOVO: Cores customizáveis para as bolinhas!
@export var cor_bolinha_ativa: Color = Color(0.2, 0.8, 0.2, 1.0) # Verde por padrão
@export var cor_bolinha_inativa: Color = Color(0.3, 0.3, 0.3, 1.0) # Cinza escuro por padrão

@export_group("Transições de Cor (Fades)")
@export var tempo_requisito_conquistado: float = 0.8 
@export var tempo_desbloqueando: float = 0.2         

@export_group("Sons")
@export var som_hover: AudioStream
@export_range(-40.0, 10.0) var volume_hover_db: float = 0.0

@export var som_clique: AudioStream
@export_range(-40.0, 10.0) var volume_clique_db: float = 0.0

@export var som_erro: AudioStream
@export_range(-40.0, 10.0) var volume_erro_db: float = 0.0

@export var pitch_min: float = 0.9
@export var pitch_max: float = 1.1

@export_group("Configurações do Tooltip")
@export var area_limite_tooltip: Control 
@export var offset_mouse: Vector2 = Vector2(20, 25) 
@export var margem_borda: Vector2 = Vector2(15, 15) 
@export var escala_tooltip: Vector2 = Vector2(1.0, 1.0) 

var travado: bool = false 
var sfx_player: AudioStreamPlayer

var tween_escala: Tween
var tween_cor: Tween 
var inicializado: bool = false 

enum EstadoUI { BLOQUEADO, DISPONIVEL, COMPRADO }
var estado_visual_atual: EstadoUI = EstadoUI.BLOQUEADO
# ----------------------------------------------------------------

var nivel_atual: int = 0
var falta_requisito: bool = false

func _ready() -> void:
	tooltip.hide()
	
	if tooltip:
		tooltip.top_level = true
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down) 
	button_up.connect(_on_button_up) 
	
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	
	if visual_animado:
		visual_animado.pivot_offset = visual_animado.size / 2 
	
	if produto:
		ProgressoDB.progresso_alterado.connect(_on_progresso_alterado)
		preparar_bolinhas()
		_on_progresso_alterado()
		
		inicializado = true

# ==========================================
# SISTEMA DE VALIDAÇÃO E CORES
# ==========================================

func pode_comprar() -> bool:
	if falta_requisito: 
		return false
		
	match produto.tipo:
		ProdutoLoja.TipoProduto.ITEM_UNICO:
			return true 
		ProdutoLoja.TipoProduto.DESBLOQUEIO_UNICO:
			return nivel_atual == 0
		ProdutoLoja.TipoProduto.UPGRADE:
			return nivel_atual < produto.niveis.size() + 1
		ProdutoLoja.TipoProduto.DESBLOQUEIO_PROGRESSIVO:
			return nivel_atual < produto.niveis.size()
			
	return false

func obter_estado_visual() -> EstadoUI:
	if falta_requisito: return EstadoUI.BLOQUEADO
	if produto.tipo == ProdutoLoja.TipoProduto.ITEM_UNICO: return EstadoUI.DISPONIVEL
	if nivel_atual == 0: return EstadoUI.DISPONIVEL
	return EstadoUI.COMPRADO

func obter_cor_de_estado(estado: EstadoUI) -> Color:
	if estado == EstadoUI.BLOQUEADO: return cor_bloqueado
	if estado == EstadoUI.DISPONIVEL:
		if produto.tipo == ProdutoLoja.TipoProduto.ITEM_UNICO: return cor_desbloqueado
		return cor_disponivel
	return cor_desbloqueado

func disparar_erro() -> void:
	_tocar_som(som_erro, volume_erro_db)
	
	if fundo_colorido:
		if tween_cor and tween_cor.is_valid():
			tween_cor.kill()
			
		var cor_base = obter_cor_de_estado(estado_visual_atual)
		fundo_colorido.modulate = cor_erro_piscar 
		
		tween_cor = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween_cor.tween_property(fundo_colorido, "modulate", cor_base, 0.3)

# ==========================================
# LÓGICA DE ANIMAÇÃO E INTERAÇÃO
# ==========================================

func _on_mouse_entered() -> void: 
	tooltip.show()
	if travado: return
	_animar_escala(escala_hover) 
	_tocar_som(som_hover, volume_hover_db)

func _on_mouse_exited() -> void: 
	tooltip.hide()
	if travado: return
	_animar_escala(escala_normal) 

func _on_button_down() -> void: 
	if travado: return
	_animar_escala(escala_clique)
	
	if pode_comprar():
		_tocar_som(som_clique, volume_clique_db)
	else:
		disparar_erro()

func _on_button_up() -> void: 
	if travado: return
	var target = escala_hover if is_hovered() else escala_normal
	_animar_escala(target)

func _animar_escala(target_scale: Vector2) -> void: 
	if not visual_animado: return 
	
	if tween_escala and tween_escala.is_valid():
		tween_escala.kill()
		
	tween_escala = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT) 
	tween_escala.tween_property(visual_animado, "scale", target_scale, tempo_transicao)

func _tocar_som(stream: AudioStream, volume: float) -> void:
	if stream:
		sfx_player.stream = stream
		sfx_player.volume_db = volume
		sfx_player.pitch_scale = randf_range(pitch_min, pitch_max)
		sfx_player.play()

# ==========================================
# LÓGICA DA LOJA E PROGRESSÃO
# ==========================================

func _on_progresso_alterado() -> void:
	sincronizar_niveis()
	verificar_pre_requisitos()
	atualizar_visual()
	

func sincronizar_niveis() -> void:
	if produto.tipo == ProdutoLoja.TipoProduto.ITEM_UNICO:
		return 
		
	var nivel_salvo = ProgressoDB.get_nivel(produto.nome)
	if produto.tipo == ProdutoLoja.TipoProduto.UPGRADE:
		nivel_atual = max(1, nivel_salvo) 
	else:
		nivel_atual = max(0, nivel_salvo) 

func verificar_pre_requisitos() -> void:
	falta_requisito = false
	for req in produto.pre_requisitos:
		if not ProgressoDB.tem_desbloqueado(req.nome):
			falta_requisito = true
			break

func _pressed() -> void:
	if pode_comprar():
		efetivar_compra()

func efetivar_compra() -> void:
	match produto.tipo:
		ProdutoLoja.TipoProduto.ITEM_UNICO:
			print("Item Único Comprado: Vai para o Inventário")
			
		ProdutoLoja.TipoProduto.DESBLOQUEIO_UNICO:
			nivel_atual = 1
			ProgressoDB.desbloquear(produto.nome, nivel_atual)
			
		ProdutoLoja.TipoProduto.UPGRADE, ProdutoLoja.TipoProduto.DESBLOQUEIO_PROGRESSIVO:
			nivel_atual += 1
			ProgressoDB.desbloquear(produto.nome, nivel_atual)

# ==========================================
# ATUALIZAÇÃO VISUAL (BOLINHAS E CORES)
# ==========================================

func atualizar_visual() -> void:
	if %IconeProduto: %IconeProduto.texture = produto.icone
	if %TooltipNome: %TooltipNome.text = produto.nome
	
	if fundo_colorido:
		var novo_estado = obter_estado_visual()
		var cor_alvo = obter_cor_de_estado(novo_estado)
		
		if not inicializado:
			fundo_colorido.modulate = cor_alvo
			estado_visual_atual = novo_estado
		elif estado_visual_atual != novo_estado:
			var tempo_fade = 0.3
			if estado_visual_atual == EstadoUI.BLOQUEADO and novo_estado == EstadoUI.DISPONIVEL:
				tempo_fade = tempo_requisito_conquistado
			elif estado_visual_atual == EstadoUI.DISPONIVEL and novo_estado == EstadoUI.COMPRADO:
				tempo_fade = tempo_desbloqueando
				
			if tween_cor and tween_cor.is_valid():
				tween_cor.kill()
				
			tween_cor = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			tween_cor.tween_property(fundo_colorido, "modulate", cor_alvo, tempo_fade)
			
			estado_visual_atual = novo_estado
		
	if produto.tipo == ProdutoLoja.TipoProduto.UPGRADE or produto.tipo == ProdutoLoja.TipoProduto.DESBLOQUEIO_PROGRESSIVO:
		
		# --- NOVA LÓGICA DE VISIBILIDADE ---
		var caixa_fundo = %ContainerBolinhas.get_parent()
		if produto.tipo == ProdutoLoja.TipoProduto.DESBLOQUEIO_PROGRESSIVO and nivel_atual == 0:
			caixa_fundo.hide() # Oculta tudo (fundo e bolinhas) se for Progressivo no Nível 0
		else:
			caixa_fundo.show() # Garante que vai aparecer pro Upgrade (Nv 1+) e pro Progressivo (Nv 1+)
		# -----------------------------------
		
		for i in range(%ContainerBolinhas.get_child_count()):
			var aspect = %ContainerBolinhas.get_child(i)
			var bolinha = aspect.get_child(0) 
			
			var estilo = bolinha.get_theme_stylebox("panel").duplicate()
			
			# NOVO: Usa as variáveis do Inspector!
			if i < nivel_atual: 
				estilo.bg_color = cor_bolinha_ativa 
			else: 
				estilo.bg_color = cor_bolinha_inativa 
				
			bolinha.add_theme_stylebox_override("panel", estilo)
			
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
			texto_final = produto.descricao_simples
			if nivel_atual == 0:
				item_custo = produto.custo_item_simples
				qtd_custo = produto.custo_quantidade_simples
			else:
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

	if item_custo == null:
		mostrar_custo = false

	if %TooltipDescricao: %TooltipDescricao.text = texto_final
	
	if mostrar_custo:
		%AreaDoPreco.show()
		if %TooltipCustoValor: %TooltipCustoValor.text = str(qtd_custo)
		if %TooltipCustoIcone and item_custo: %TooltipCustoIcone.texture = item_custo.icone
	else:
		%AreaDoPreco.hide() 
		%TooltipBox.size = Vector2.ZERO

func preparar_bolinhas() -> void:
	for child in %ContainerBolinhas.get_children():
		child.queue_free()
		
	var qtd_bolinhas = 0
	if produto.tipo == ProdutoLoja.TipoProduto.UPGRADE:
		qtd_bolinhas = produto.niveis.size() + 1
	elif produto.tipo == ProdutoLoja.TipoProduto.DESBLOQUEIO_PROGRESSIVO:
		qtd_bolinhas = produto.niveis.size()
		
	var caixa_fundo = %ContainerBolinhas.get_parent()
	if qtd_bolinhas == 0:
		caixa_fundo.hide()
		return
	else:
		caixa_fundo.show()
		caixa_fundo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		caixa_fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	for i in range(qtd_bolinhas):
		var aspect = AspectRatioContainer.new()
		aspect.stretch_mode = AspectRatioContainer.STRETCH_FIT
		aspect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var bolinha = Panel.new()
		bolinha.custom_minimum_size = Vector2(10, 10) 
		bolinha.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var estilo = StyleBoxFlat.new()
		estilo.corner_radius_top_left = 4
		estilo.corner_radius_top_right = 4
		estilo.corner_radius_bottom_left = 4
		estilo.corner_radius_bottom_right = 4
		# NOVO: Usa a cor inativa configurada no Inspector ao criar a bolinha
		estilo.bg_color = cor_bolinha_inativa 
		
		bolinha.add_theme_stylebox_override("panel", estilo)
		
		aspect.add_child(bolinha)
		%ContainerBolinhas.add_child(aspect)
		

# ==========================================
# POSICIONAMENTO DO TOOLTIP
# ==========================================
func _process(_delta: float) -> void:
	if tooltip.visible:
		tooltip.scale = escala_tooltip 
		
		var mouse_pos = get_global_mouse_position()
		var t_size = tooltip.size * escala_tooltip 
		
		var rect_limite = Rect2(Vector2.ZERO, get_viewport_rect().size)
		if area_limite_tooltip:
			rect_limite = Rect2(area_limite_tooltip.global_position, area_limite_tooltip.size)
			
		var pos_alvo = mouse_pos + offset_mouse
		
		var limite_max_x = rect_limite.position.x + rect_limite.size.x - margem_borda.x
		var limite_max_y = rect_limite.position.y + rect_limite.size.y - margem_borda.y
		
		if pos_alvo.x + t_size.x > limite_max_x:
			pos_alvo.x = mouse_pos.x - t_size.x - offset_mouse.x
			
		if pos_alvo.y + t_size.y > limite_max_y:
			pos_alvo.y = mouse_pos.y - t_size.y - offset_mouse.y
			
		pos_alvo.x = max(pos_alvo.x, rect_limite.position.x + margem_borda.x)
		pos_alvo.y = max(pos_alvo.y, rect_limite.position.y + margem_borda.y)
		
		tooltip.global_position = pos_alvo
