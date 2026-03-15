extends PanelContainer

@onready var code_edit = %CodeEdit
@onready var botao_executar = %BotaoExecutar 

var modo_atual: String = "vilarejo"

func _ready() -> void:
	botao_executar.focus_mode = Control.FOCUS_NONE
	code_edit.focus_mode = Control.FOCUS_CLICK

func ativar_modo_vilarejo():
	modo_atual = "vilarejo"
	code_edit.editable = true
	botao_executar.visible = true
	botao_executar.text = "Rodar Código"

func ativar_modo_arena():
	modo_atual = "arena"
	code_edit.editable = false
	botao_executar.visible = true
	botao_executar.text = "Parar e Escapar"

func _on_botao_executar_pressed() -> void:
	if modo_atual == "vilarejo":
		print("[PROTÓTIPO UI] Clique em RODAR CÓDIGO. (No futuro, isso chamará o Interpretador C# e o Main.gd)")
			
	elif modo_atual == "arena":
		print("[PROTÓTIPO UI] Clique em PARAR E ESCAPAR. (No futuro, isso interromperá o C# e voltará ao Vilarejo)")
