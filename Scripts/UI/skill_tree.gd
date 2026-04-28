extends Control

var arrastando: bool = false

@export var zoom_minimo: float = 0.3  
@export var zoom_maximo: float = 2.0
@export var zoom_velocidade: float = 0.1
@export var zoom_inicial: float = 1.0 
@export var suavizacao_zoom: float = 15.0

var zoom_atual: float = 1.0
var zoom_alvo: float = 1.0

@onready var canvas = $CanvasArraste
@onready var container_conexoes = $CanvasArraste/Conexoes

func _ready() -> void:
	zoom_alvo = clamp(zoom_inicial, zoom_minimo, zoom_maximo)
	zoom_atual = zoom_alvo
	canvas.scale = Vector2(zoom_atual, zoom_atual)
	
	if canvas.has_node("AreaLimite"):
		canvas.get_node("AreaLimite").visible = false
		
	call_deferred("centralizar_no_inicio")

func centralizar_no_inicio() -> void:
	if canvas.has_node("CentroFoco"):
		var tamanho_da_mascara = size 
		var alvo = canvas.get_node("CentroFoco").position * zoom_atual
		canvas.position = (tamanho_da_mascara / 2.0) - alvo
		aplicar_limites_da_area()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			arrastando = event.pressed
				
	if event is InputEventMouseMotion and arrastando:
		canvas.position += event.relative 
		aplicar_limites_da_area()
		
	if event is InputEventMouseButton and event.pressed:
		var direcao_zoom = 0
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: direcao_zoom = 1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: direcao_zoom = -1
			
		if direcao_zoom != 0:
			zoom_alvo += direcao_zoom * zoom_velocidade
			zoom_alvo = clamp(zoom_alvo, zoom_minimo, zoom_maximo)

func _process(delta: float) -> void:
	if abs(zoom_atual - zoom_alvo) > 0.001:
		var zoom_anterior = zoom_atual
		zoom_atual = lerp(zoom_atual, zoom_alvo, suavizacao_zoom * delta)
		
		if abs(zoom_atual - zoom_alvo) <= 0.001:
			zoom_atual = zoom_alvo
			
		var mouse_pos = get_local_mouse_position()
		var offset_mouse = mouse_pos - canvas.position
		var fator_escala = zoom_atual / zoom_anterior
		
		canvas.position = mouse_pos - (offset_mouse * fator_escala)
		canvas.scale = Vector2(zoom_atual, zoom_atual)
		
		aplicar_limites_da_area()

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

func encontrar_botao_do_produto(produto_alvo: ProdutoLoja) -> Node:
	for botao in canvas.get_children():
		if botao is Button and "produto" in botao and botao.produto == produto_alvo:
			return botao
	return null
