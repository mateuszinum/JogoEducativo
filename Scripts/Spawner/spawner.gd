extends Node2D

@export var player : CharacterBody2D
@export var enemy_scene : PackedScene
@export var max_enemies : int = 300

# Aqui você arrasta o seu arquivo .tres da fase atual!
@export var current_stage : StageData 

var distance : float = 400
var total_time_seconds : int = 0

# Dicionário que guarda quem está nascendo agora e a quantidade por segundo.
# Estrutura: { EnemyResource : spawn_rate_int }
var active_spawns : Dictionary = {}

func _ready():
	# Força a leitura inicial no segundo 0
	check_spawn_events()

func spawn(pos : Vector2, type_to_spawn: Enemy):
	if get_tree().get_node_count_in_group("Enemy") >= max_enemies:
		return

	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.type = type_to_spawn
	enemy_instance.position = pos
	enemy_instance.player_reference = player
	
	get_tree().current_scene.add_child(enemy_instance)

func get_random_position() -> Vector2:
	return player.position + distance * Vector2.RIGHT.rotated(randf_range(0, 2 * PI))

# O Timer de 1 segundo que você já tinha
func _on_timer_timeout() -> void:
	total_time_seconds += 1
	update_ui_clock()
	
	# 1. Checa se tem alguma regra nova para esse exato segundo
	check_spawn_events()
	
	# 2. Spawna os inimigos baseados nas taxas ativas atuais
	execute_spawns()

func check_spawn_events():
	if current_stage == null: return
	
	for event in current_stage.spawn_events:
		if event.time_in_seconds == total_time_seconds:
			if event.spawn_rate > 0:
				# Atualiza ou adiciona o inimigo na lista de spawns ativos
				active_spawns[event.enemy_type] = event.spawn_rate
				print("Evento: Começando a spawnar ", event.enemy_type.title, " a ", event.spawn_rate, "/s")
			else:
				# Se a taxa for 0, removemos ele da lista de spawns ativos
				active_spawns.erase(event.enemy_type)
				print("Evento: Parando de spawnar ", event.enemy_type.title)

func execute_spawns():
	# Para cada inimigo que está "ativo" no momento, spawna a quantidade dele
	for enemy_type in active_spawns:
		var amount_to_spawn = active_spawns[enemy_type]
		
		for i in range(amount_to_spawn):
			spawn(get_random_position(), enemy_type)

func update_ui_clock():
	var m = total_time_seconds / 60
	var s = total_time_seconds % 60
	%Minute.text = str(m)
	%Seconds.text = str(s).lpad(2, '0')
