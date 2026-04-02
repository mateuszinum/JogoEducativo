extends Area2D

@export var config: TesouroData

const CENA_BASE_DO_DROP = preload("res://Scenes/Drops/drop.tscn")

func _ready():
	if config and config.sprite_do_bau:
		$Sprite2D.texture = config.sprite_do_bau

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if config and "tabela_de_drops" in config and config.tabela_de_drops != null:
			for drop in config.tabela_de_drops:
				var sorteio = randf() * 100.0 
				
				if sorteio <= drop.chance_de_drop:
					var qtd_sorteada = randi_range(drop.quantidade_minima, drop.quantidade_maxima)
					for i in range(qtd_sorteada):
						var novo_drop = CENA_BASE_DO_DROP.instantiate()
						novo_drop.configurar(drop.item, 1)
						novo_drop.global_position = global_position
						get_parent().call_deferred("add_child", novo_drop)
		
		var mapa = get_tree().get_first_node_in_group("Mundo")
		if mapa:
			mapa.gerar_tesouro() 
			
		print("Pegou o tesouro e dropou os itens!")
		queue_free()
