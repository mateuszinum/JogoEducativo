extends HBoxContainer

@export var cena_pocao: PackedScene 

func _ready():
	add_to_group("UI_Pocoes")

func adicionar_pocao(nome_identificador: String, icone: Texture2D, tempo: float, cor: Color):
	var timer_existente = get_node_or_null(nome_identificador)
	
	if timer_existente:
		timer_existente.adicionar_tempo(tempo)
	else:
		if cena_pocao:
			var nova_pocao = cena_pocao.instantiate()
			nova_pocao.name = nome_identificador 
			add_child(nova_pocao)
			nova_pocao.iniciar(icone, tempo, cor)
