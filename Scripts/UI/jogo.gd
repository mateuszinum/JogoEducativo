extends Control

@onready var viewport = %SubViewport
@onready var terminal = %PainelTerminal

const CENA_VILAREJO = preload("res://Scenes/UI/village_menu.tscn")
const CENA_ARENA = preload("res://Scenes/World/world.tscn")

func _ready() -> void:
	ir_para_vilarejo()

func ir_para_vilarejo() -> void:
	limpar_viewport()
	if not CENA_VILAREJO: return
	
	var vilarejo = CENA_VILAREJO.instantiate()
	viewport.add_child(vilarejo)
	
	if terminal.has_method("ativar_modo_vilarejo"):
		terminal.ativar_modo_vilarejo()

func ir_para_arena() -> void:
	limpar_viewport()
	if not CENA_ARENA: return
	
	var arena = CENA_ARENA.instantiate()
	viewport.add_child(arena)
	
	if terminal.has_method("ativar_modo_arena"):
		terminal.ativar_modo_arena()

func limpar_viewport() -> void:
	if viewport:
		for child in viewport.get_children():
			child.queue_free()
