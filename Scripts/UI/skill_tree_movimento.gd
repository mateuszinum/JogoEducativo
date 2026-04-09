extends Control

var arrastando: bool = false

# --- CONFIGURAÇÕES DE ZOOM ---
@export var zoom_minimo: float = 0.3  
@export var zoom_maximo: float = 2.0
@export var zoom_velocidade: float = 0.1
@export var zoom_inicial: float = 1.0 
var zoom_atual: float = 1.0

# Referências aos filhos
@onready var canvas = $CanvasArraste
@onready var container_conexoes = $CanvasArraste/Conexoes

func _ready() -> void:
	zoom_atual = clamp(zoom_inicial, zoom_minimo, zoom_maximo)
	canvas.scale = Vector2(zoom_atual, zoom_atual)
	
	if canvas.has_node("AreaLimite"):
		canvas.get_node("AreaLimite").visible = false
		
	call_deferred("centralizar_no_inicio")
	call_deferred("desenhar_linhas_da_arvore")

func centralizar_no_inicio() -> void:
	if canvas.has_node("CentroFoco"):
		var tamanho_da_mascara = size # Agora o próprio nó pai é o tamanho da tela
		var alvo = canvas.get_node("CentroFoco").position * zoom_atual
		canvas.position = (tamanho_da_mascara / 2.0) - alvo
		aplicar_limites_da_area()

func _gui_input(event: InputEvent) -> void:
	# 1. ARRASTAR A TELA
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			arrastando = event.pressed
				
	if event is InputEventMouseMotion and arrastando:
		# Movemos o canvas, não a máscara
		canvas.position += event.relative 
		aplicar_limites_da_area()
		
	# 2. DAR ZOOM
	if event is InputEventMouseButton and event.pressed:
		var direcao_zoom = 0
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: direcao_zoom = 1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: direcao_zoom = -1
			
		if direcao_zoom != 0:
			var zoom_anterior = zoom_atual
			zoom_atual += direcao_zoom * zoom_velocidade
			zoom_atual = clamp(zoom_atual, zoom_minimo, zoom_maximo)
			
			# Nova matemática de zoom (Perfeita para a câmera externa)
			var mouse_pos = get_local_mouse_position()
			var offset_mouse = mouse_pos - canvas.position
			var fator_escala = zoom_atual / zoom_anterior
			
			canvas.position = mouse_pos - (offset_mouse * fator_escala)
			canvas.scale = Vector2(zoom_atual, zoom_atual)
			
			aplicar_limites_da_area()

# ==========================================
# CÁLCULO DE LIMITES INTELIGENTE
# ==========================================
func aplicar_limites_da_area() -> void:
	if not canvas.has_node("AreaLimite"): return
	
	var area = canvas.get_node("AreaLimite")
	var tamanho_tela = size 
	
	var limite_x_min = tamanho_tela.x - (area.position.x + area.size.x) * zoom_atual
	var limite_x_max = -area.position.x * zoom_atual
	
	var limite_y_min = tamanho_tela.y - (area.position.y + area.size.y) * zoom_atual
	var limite_y_max = -area.position.y * zoom_atual
	
	var trava_x_min = min(limite_x_min, limite_x_max)
	var trava_x_max = max(limite_x_min, limite_x_max)
	var trava_y_min = min(limite_y_min, limite_y_max)
	var trava_y_max = max(limite_y_min, limite_y_max)
	
	canvas.position.x = clamp(canvas.position.x, trava_x_min, trava_x_max)
	canvas.position.y = clamp(canvas.position.y, trava_y_min, trava_y_max)

# ==========================================
# DESENHO DAS CONEXÕES
# ==========================================
func desenhar_linhas_da_arvore() -> void:
	for child in container_conexoes.get_children():
		child.queue_free()
		
	for botao in canvas.get_children():
		if botao is Button and "produto" in botao and botao.produto != null:
			for requisito in botao.produto.pre_requisitos:
				var botao_pai = encontrar_botao_do_produto(requisito)
				if botao_pai != null:
					var linha = Line2D.new()
					linha.add_point(botao_pai.position + (botao_pai.size / 2.0))
					linha.add_point(botao.position + (botao.size / 2.0))
					linha.width = 4.0
					linha.default_color = Color(0.4, 0.4, 0.4, 1.0) 
					linha.z_index = -1 
					container_conexoes.add_child(linha)

func encontrar_botao_do_produto(produto_alvo: ProdutoLoja) -> Node:
	for botao in canvas.get_children():
		if botao is Button and "produto" in botao and botao.produto == produto_alvo:
			return botao
	return null
