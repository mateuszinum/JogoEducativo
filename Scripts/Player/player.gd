extends CharacterBody2D

# Quantidade de pixels que o player mexe por ativação
const tile_size = 16
var moving:bool = false
var input_dir

var enemies_in_range : Array[CharacterBody2D] = []
var nearest_enemy : CharacterBody2D = null
	
func _physics_process(_delta: float) -> void:
	nearest_enemy = get_nearest_enemy()
	
	# Processa cada tecla de movimentação que o player aperta e atribui uma direção para input_dir
	input_dir = Vector2.ZERO

	var dirs = {
		"ui_up":    Vector2.UP,
		"ui_down":  Vector2.DOWN,
		"ui_left":  Vector2.LEFT,
		"ui_right": Vector2.RIGHT
	}

	for action in dirs:
		if Input.is_action_just_pressed(action):
			input_dir = dirs[action]
			move()
			break

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

func _on_enemy_detector_body_entered(body):
	if body is CharacterBody2D:
		enemies_in_range.append(body)

func _on_enemy_detector_body_exited(body):
	enemies_in_range.erase(body)

func get_nearest_enemy() -> CharacterBody2D:
	var nearest : CharacterBody2D = null
	var min_distance := INF

	for enemy in enemies_in_range:
		var distance = global_position.distance_squared_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest = enemy

	return nearest
