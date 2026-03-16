extends CharacterBody2D

const OPACIDADE_NO_DANO : float = 1.0

var fila_comandos: Array[String] = [] # O nosso "caderninho" de anotações

@onready var anim = $AnimatedSprite2D
signal health_changed(current_health)

@export var health = 50
@export var max_health = health
@export var touch_knockback_multiplier: float = 1.0
@export var global_knockback_multiplier: float = 1.0

@export_group("Atributos")
@export var agilidade: float = 1.0 # 1.0 é a velocidade normal de processamento
@export var tempo_base_acao: float = 0.5 # Segundos que ele espera entre cada comando

var aguardando_agilidade: bool = false # Uma trava para o cooldown

@export_group("Audio")
@export var hurt_sound : AudioStream
@export var hurt_volume : float = 0.0
@export var hurt_pitch_min : float = 0.8
@export var hurt_pitch_max : float = 1.2
@export var step_sound : AudioStream
@export var step_volume : float = 0.0
@export var step_pitch_min : float = 0.8
@export var step_pitch_max : float = 1.2

const tile_size = 16
var moving : bool = false
var input_dir

@export_group("Inventory")
@export var inventario_armas : Array[Weapon] = []
var indice_arma_atual : int = 0
var arma_equipada : Weapon = null

var enemies_in_range : Array[CharacterBody2D] = []
var nearest_enemy : CharacterBody2D = null

func _ready() -> void:
	anim.play("default")
	if inventario_armas.size() > 0:
		arma_equipada = inventario_armas[0]
		%WeaponSlot.weapon = arma_equipada
		
func trocar_arma() -> void:
	if inventario_armas.is_empty():
		return
		
	indice_arma_atual += 1
	if indice_arma_atual >= inventario_armas.size():
		indice_arma_atual = 0
		
	arma_equipada = inventario_armas[indice_arma_atual]
	%WeaponSlot.weapon = arma_equipada 

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("change_weapon"):
		trocar_arma()
		
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
			
	# --- NOSSA NOVA LINHA ---
	processar_fila() # Fica checando se a mente mandou o corpo agir

func move():
	if input_dir == Vector2.ZERO or moving:
		return

	$RayCast2D.target_position = input_dir * tile_size
	$RayCast2D.force_raycast_update()

	if $RayCast2D.is_colliding():
		return 
	
	if input_dir.x != 0:
		anim.flip_h = (input_dir.x < 0)
	
	moving = true
	
	if step_sound != null:
		var audio = AudioStreamPlayer2D.new()
		audio.stream = step_sound
		audio.volume_db = step_volume
		audio.global_position = global_position
		audio.pitch_scale = randf_range(step_pitch_min, step_pitch_max)
		get_parent().add_child(audio)
		audio.play()
		audio.finished.connect(audio.queue_free)
	
	var tween = create_tween()
	tween.tween_property(self, "position", position + input_dir * tile_size, 0.05)
	tween.tween_callback(move_false)

	var squash_tween = create_tween()
	squash_tween.tween_property(anim, "scale", Vector2(1.6, 0.6), 0.025)
	squash_tween.tween_property(anim, "scale", Vector2(1.0, 1.0), 0.025)

func move_false():
	moving = false
	
func take_damage(amount):
	if $DamageTick.time_left > 0:
		return
	
	health -= amount
	health_changed.emit(health)
	
	$DamageTick.start()
	
	modulate.a = OPACIDADE_NO_DANO
	
	anim.modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(anim, "modulate", Color.WHITE, 0.2)
	
	anim.play("hurt")
	
	if hurt_sound != null:
		var audio = AudioStreamPlayer2D.new()
		audio.stream = hurt_sound
		audio.volume_db = hurt_volume
		audio.global_position = global_position
		audio.pitch_scale = randf_range(hurt_pitch_min, hurt_pitch_max)
		get_parent().add_child(audio)
		audio.play()
		audio.finished.connect(audio.queue_free)

func _on_enemy_detector_body_entered(body):
	if body.is_in_group("Enemy"):
		enemies_in_range.append(body)

func _on_enemy_detector_body_exited(body):
	enemies_in_range.erase(body)

func _on_nearest_enemy_timer_timeout():
	if enemies_in_range.size() > 0:
		nearest_enemy = InimigoMaisProximo.get_nearest_enemy(global_position, enemies_in_range)
	else:
		nearest_enemy = null
	
func _on_self_damage_body_entered(body: Node2D) -> void:
	if "damage" in body:
		take_damage(body.damage)
	
	if body.has_method("apply_knockback"):
		var knockback_dir = global_position.direction_to(body.global_position)
		body.apply_knockback(touch_knockback_multiplier, knockback_dir)

func _on_damage_tick_timeout() -> void:
	modulate.a = 1
	anim.play("default")
	
func mover(direcao: String) -> void:
	# O C# agora apenas anota o pedido no final da fila, super rápido!
	fila_comandos.append(direcao)

func processar_fila() -> void:
	# 1. Verifica as travas: pulando, fila vazia, ou ainda no cooldown da agilidade
	if moving or fila_comandos.is_empty() or aguardando_agilidade:
		return
		
	# 2. Ativa a trava de cooldown
	aguardando_agilidade = true
		
	# 3. Pega o próximo comando e apaga do caderninho
	var proximo_comando = fila_comandos.pop_front() 
	
	if proximo_comando == "norte":
		input_dir = Vector2.UP
	elif proximo_comando == "sul":
		input_dir = Vector2.DOWN
	elif proximo_comando == "leste":
		input_dir = Vector2.RIGHT
	elif proximo_comando == "oeste":
		input_dir = Vector2.LEFT
	else:
		aguardando_agilidade = false # Destrava se o comando for inválido
		return
		
	# 4. Aciona a sua função original para fazer a animação e andar
	move()
	
	# === A MÁGICA DA AGILIDADE AQUI ===
	var tempo_de_espera = tempo_base_acao / agilidade
	
	# O Godot cria um cronômetro invisível e pausa a execução DESTA função até o tempo acabar
	await get_tree().create_timer(tempo_de_espera).timeout
	
	# 5. O tempo acabou! Libera o personagem para ler o próximo comando da fila
	aguardando_agilidade = false
	# Se já estiver pulando ou não tiver nada anotado, não faz nada
	if moving or fila_comandos.is_empty():
		return
	
	if proximo_comando == "norte":
		input_dir = Vector2.UP
	elif proximo_comando == "sul":
		input_dir = Vector2.DOWN
	elif proximo_comando == "leste":
		input_dir = Vector2.RIGHT
	elif proximo_comando == "oeste":
		input_dir = Vector2.LEFT
	else:
		return
		
	# Inicia a animação do pulo
	move()

func atacar(alvo: String, tipo: String) -> void:
	print("[Player] Ordem recebida do C#: Atacar alvo '", alvo, "' com elemento '", tipo, "'")
	
	# Aqui no futuro vamos instanciar a arma (flecha, fogo, gelo) 
	# e disparar na direção do nearest_enemy (inimigo mais próximo)
	if nearest_enemy != null:
		print("Atirando no inimigo: ", nearest_enemy.name)
	else:
		print("Nenhum inimigo no alcance!")
