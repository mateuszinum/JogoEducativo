extends CharacterBody2D

@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D

signal health_changed(current_health)

@export var health = 50
@export var max_health = health

# Quantidade de pixels que o player mexe por ativação
const tile_size = 16
var moving : bool = false
var input_dir

# Isso vai criar um espaço no Inspetor do Player para você arrastar suas armas (.tres)
@export var inventario_armas : Array[Weapon] = []
var indice_arma_atual : int = 0
var arma_equipada : Weapon = null

func _ready() -> void:
	anim.play("walk")
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
	if Input.is_action_just_pressed("change_weapon"):
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
	
	# Lógica de espelhamento (Flip)
	if input_dir.x != 0:
		sprite.flip_h = (input_dir.x < 0)
	
	moving = true
	
	var move_tween = create_tween()
	move_tween.tween_property(self, "position", position + input_dir * tile_size, 0.075)
	move_tween.tween_callback(move_false)

	var squash_tween = create_tween()
	squash_tween.tween_property(sprite, "scale", Vector2(1.4, 0.7), 0.025)
	squash_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.025)

func move_false():
	moving = false
	
func take_damage(amount):
	if $DamageTick.time_left > 0:
		return
	
	health -= amount
	health_changed.emit(health)
	print("Você tomou " + str(amount) + " de dano!")
	
	$DamageTick.start()
	
	modulate.a = 0.5

func _on_enemy_detector_body_entered(body):
	if body.is_in_group("Enemy"):
		enemies_in_range.append(body)

func _on_enemy_detector_body_exited(body):
	enemies_in_range.erase(body)

func _on_nearest_enemy_timer_timeout():
	nearest_enemy = InimigoMaisProximo.get_nearest_enemy(global_position, enemies_in_range)
	
func _on_self_damage_body_entered(body: Node2D) -> void:
	take_damage(body.damage)

func _on_damage_tick_timeout() -> void:
	modulate.a = 1
