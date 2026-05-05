extends Control

@export var cutscene_exemplo: String

func _ready() -> void:
	visible = false
	
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

func _on_botao_agilidade_pressed() -> void:
	Atributos.maximizar_agilidade()

func _on_botao_musica_pressed() -> void:
	if Constantes.VOLUME_MUSICA == 0.0:
		Constantes.VOLUME_MUSICA = 0.5
	else:
		Constantes.VOLUME_MUSICA = 0.0

func _on_botao_cutscene_pressed() -> void:
	CutsceneManager.tocar_cutscene(cutscene_exemplo)

func _on_botao_morrer_pressed() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("take_damage"):
		player.take_damage(999)
