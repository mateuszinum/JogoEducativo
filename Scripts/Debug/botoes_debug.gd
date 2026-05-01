extends Control

@onready var botao_codigo = $BotaoDebug
@onready var botao_recurso = $BotaoRecurso

func _ready() -> void:
	visible = false
	
	if Constantes.MODO_DEV:
		if botao_codigo:
			botao_codigo.pressed.connect(_on_botao_debug_codigo_pressed)
			botao_codigo.focus_mode = Control.FOCUS_NONE
			
		if botao_recurso:
			botao_recurso.pressed.connect(_on_botao_recurso_pressed)
			botao_recurso.focus_mode = Control.FOCUS_NONE

func _process(_delta: float) -> void:
	if Constantes.MODO_DEV:
		visible = Input.is_physical_key_pressed(KEY_TAB)

func _on_botao_debug_codigo_pressed() -> void:
	var terminal = get_tree().get_first_node_in_group("Terminal")
	
	if terminal and terminal.has_method("definir_codigo_slot"):
		for i in range(5):
			var codigo_puxado = CodigosDebug.obter_codigo(i)
			terminal.definir_codigo_slot(i, codigo_puxado)

func _on_botao_recurso_pressed() -> void:
	if RecursosManager.has_method("receberRecurso"):
		RecursosManager.receberRecurso("Couro", 100)
		RecursosManager.receberRecurso("Cristal", 200)
		RecursosManager.receberRecurso("Diamante", 300)
		RecursosManager.receberRecurso("Esmeralda", 400)
		RecursosManager.receberRecurso("Magma", 500)
		RecursosManager.receberRecurso("Moeda", 9000000)
		RecursosManager.receberRecurso("Osso", 1000)
		RecursosManager.receberRecurso("Plasma", 56)
		RecursosManager.receberRecurso("Safira", 275)
		RecursosManager.receberRecurso("Sangue", 5125)
