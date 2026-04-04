extends Control

@onready var musica_vilarejo = $MusicaVilarejo

# Referências para todas as lojas instanciadas
@onready var loja_bruxa = $LojaBruxa
@onready var loja_comerciante = $LojaComerciante
@onready var loja_biblioteca = $LojaBiblioteca
@onready var loja_mago_velho = $LojaMagoVelho

func _ready() -> void:
	if musica_vilarejo and not musica_vilarejo.playing:
		musica_vilarejo.volume_db = 0.0 
		musica_vilarejo.play()
		
	# Garantia de segurança: força todas as lojas a começarem escondidas
	if loja_bruxa: loja_bruxa.hide()
	if loja_comerciante: loja_comerciante.hide()
	if loja_biblioteca: loja_biblioteca.hide()
	if loja_mago_velho: loja_mago_velho.hide()

# ==========================================
# SINAIS DOS BOTÕES DO MENU (ABRIR)
# ==========================================
func _on_button_bruxa_pressed() -> void:
	if loja_bruxa: loja_bruxa.show()

func _on_button_comerciante_pressed() -> void:
	if loja_comerciante: loja_comerciante.show()

func _on_button_biblioteca_pressed() -> void:
	if loja_biblioteca: loja_biblioteca.show()

func _on_button_mago_velho_pressed() -> void:
	if loja_mago_velho: loja_mago_velho.show()

# ==========================================
# SINAIS DAS LOJAS (FECHAR)
# ==========================================
func _on_loja_bruxa_fechou_loja() -> void:
	if loja_bruxa: loja_bruxa.hide()

func _on_loja_comerciante_fechou_loja() -> void:
	if loja_comerciante: loja_comerciante.hide()

func _on_loja_biblioteca_fechou_loja() -> void:
	if loja_biblioteca: loja_biblioteca.hide()

func _on_loja_mago_velho_fechou_loja() -> void:
	if loja_mago_velho: loja_mago_velho.hide()

# ==========================================
# OUTROS BOTÕES
# ==========================================
func _on_start_game_pressed() -> void:
	var main_scene = get_node_or_null("/root/Jogo")
	if main_scene and main_scene.has_method("ir_para_arena"):
		main_scene.ir_para_arena()
