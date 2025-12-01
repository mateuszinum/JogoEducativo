extends CharacterBody2D

# Quantidade de pixels que o player mexe por ativação
const tile_size = 16
var moving:bool = false
var input_dir

var nearest_enemy : CharacterBody2D
var nearest_enemy_distance : float = INF

# Processa cada tecla de movimentação que o player aperta e atribui uma direção para input_dir
func _physics_process(_delta: float) -> void:
	if nearest_enemy:
		nearest_enemy_distance = nearest_enemy.separation
	else:
		nearest_enemy_distance = INF
		 
	input_dir = Vector2.ZERO
	if Input.is_action_just_pressed("ui_down"):
		input_dir = Vector2(0, 1)
		move()
	elif Input.is_action_just_pressed("ui_up"):
		input_dir = Vector2(0, -1)
		move()
	elif Input.is_action_just_pressed("ui_left"):
		input_dir = Vector2(-1, 0)
		move()
	elif Input.is_action_just_pressed("ui_right"):
		input_dir = Vector2(1, 0)
		move()

func move():
	if input_dir == Vector2.ZERO or moving:
		return

	# Lança Raycast para o próximo tile
	$RayCast2D.target_position = input_dir * tile_size
	$RayCast2D.force_raycast_update()

	if $RayCast2D.is_colliding():
		return # Achou barreira, não mexer
	
	# O player não consegue mudar de direção enquanto está se movimentando
	moving = true
	var tween = create_tween()
	
	# O último parâmetro define a velocidade com que o player anda de um tile para outro
	tween.tween_property(self, "position", position + input_dir * tile_size, 0.05)
	tween.tween_callback(move_false)

func move_false():
	moving = false
