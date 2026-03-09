extends CharacterBody2D

var health : float = 50:
	set(value):
		health = value
		%HealthBar.value = value

# Quantidade de pixels que o player mexe por ativação
const tile_size = 16
var moving : bool = false
var input_dir

# Isso vai criar um espaço no Inspetor do Player para você arrastar suas armas (.tres)
@export var inventario_armas : Array[Weapon] = []
var indice_arma_atual : int = 0
var arma_equipada : Weapon = null

func _ready() -> void:
	if inventario_armas.size() > 0:
		arma_equipada = inventario_armas[0]
		# AVISA O SLOT QUAL É A PRIMEIRA ARMA
		%WeaponSlot.weapon = arma_equipada
		
func trocar_arma() -> void:
	if inventario_armas.is_empty():
		return
		
	indice_arma_atual += 1
	if indice_arma_atual >= inventario_armas.size():
		indice_arma_atual = 0
		
	arma_equipada = inventario_armas[indice_arma_atual]
	# Ela pega a arma nova do inventário e joga dentro do WeaponSlot
	%WeaponSlot.weapon = arma_equipada 
	print("Arma trocada para: ", arma_equipada.resource_path)
	

		
var enemies_in_range : Array[CharacterBody2D] = []
var nearest_enemy : CharacterBody2D = null
	
func _physics_process(_delta: float) -> void:	
	# --- TROCAR DE ARMA (Aperte TAB) ---
	if Input.is_action_just_pressed("ui_focus_next"):
		trocar_arma()
	# Processa cada tecla de movimentação que o player aperta e atribui uma direção para input_dir
	input_dir = Vector2.ZERO

	var dirs = {
		"move_up":    Vector2.UP,
		"move_down":  Vector2.DOWN,
		"move_left":  Vector2.LEFT,
		"move_right": Vector2.RIGHT
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

func get_nearest_enemy() -> CharacterBody2D:
	if enemies_in_range.is_empty():
		return null
	
	var nearest : CharacterBody2D = null
	var min_distance := INF

	for enemy in enemies_in_range:
		if !is_instance_valid(enemy):
			continue
			
		var distance = global_position.distance_squared_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest = enemy

	return nearest
	
