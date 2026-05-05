extends CharacterBody2D

@onready var tile_map = $"../TileMap"
const tile_size = 32
const TEMPO_DE_PASSO : float = 0.1
const TEMPO_ANIMACAO : float = 0.05

const OPACIDADE_NO_DANO : float = 1.0

const ERROR_FEEDBACK = preload("res://Scenes/Polimento/error_feedback.tscn")

@onready var anim = $AnimatedSprite2D
signal health_changed(current_health)

var health : int
@export var touch_knockback_multiplier: float = 1.0

@export_group("Audio")
@export var hurt_sound : AudioStream
@export var hurt_volume : float = 0.0
@export var hurt_pitch_min : float = 0.8
@export var hurt_pitch_max : float = 1.2
@export var step_sound : AudioStream
@export var step_volume : float = 0.0
@export var step_pitch_min : float = 0.8
@export var step_pitch_max : float = 1.2

@export var collect_sound : AudioStream
@export var collect_volume : float = 0.0
@export var collect_pitch_min : float = 0.8
@export var collect_pitch_max : float = 2.0
@export var collect_pitch_step : float = 0.1
@export var collect_pitch_reset_time : float = 1.0 

@export_group("Interface (UI)")
@export var ui_barra_vida: CanvasItem 
@export var ui_recurso_labirinto: CanvasItem

@export_group("Animação de Game Over (Fases)")
@export_subgroup("Fase 1: Foco no Jogador")
@export var go_tempo_zoom_iris: float = 1.0
@export var go_escala_zoom: Vector2 = Vector2(2.5, 2.5)
@export var go_tamanho_iris_foco: float = 0.3
@export var go_som_foco: AudioStream
@export var go_volume_foco: float = 0.0

@export_subgroup("Fase 2 e 3: Animação e Fechar Íris")
@export var go_tempo_fechar_iris: float = 0.5
@export var go_som_fechar_iris: AudioStream
@export var go_volume_fechar_iris: float = 0.0

@export_subgroup("Fase 4 e 5: Texto e Retorno")
@export var go_tempo_fade_texto: float = 1.0
@export var go_tempo_espera_final: float = 2.0
@export var go_som_texto: AudioStream
@export var go_volume_som_texto: float = 0.0

var _current_collect_pitch : float = 0.8
var _pitch_direction : int = 1
var _pitch_reset_timer : float = 0.0

var invulneravel : bool = false

var moving : bool = false
var input_dir : Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("Player") 
	anim.play("default")
	_current_collect_pitch = collect_pitch_min
	health = Atributos.max_health
	
func _physics_process(delta: float) -> void:		
	if Constantes.MODO_DEV:
		var dirs = {
			"move_up":    "Cima",
			"move_down":  "Baixo",
			"move_left":  "Esquerda",
			"move_right": "Direita"
		}
		for action in dirs:
			if Input.is_action_just_pressed(action):
				FuncoesNativas.mover(dirs[action])
			
	if _pitch_reset_timer > 0:
		_pitch_reset_timer -= delta
		if _pitch_reset_timer <= 0:
			_current_collect_pitch = collect_pitch_min
			_pitch_direction = 1

func tocar_som_coleta() -> void:
	if collect_sound != null:
		var audio = AudioStreamPlayer2D.new()
		audio.stream = collect_sound
		audio.volume_db = collect_volume
		audio.bus = "SFX"
		audio.global_position = global_position
		audio.pitch_scale = _current_collect_pitch
		get_parent().add_child(audio)
		audio.play()
		audio.finished.connect(audio.queue_free)

		_current_collect_pitch += collect_pitch_step * _pitch_direction

		if _current_collect_pitch >= collect_pitch_max:
			_current_collect_pitch = collect_pitch_max
			_pitch_direction = -1 
		elif _current_collect_pitch <= collect_pitch_min:
			_current_collect_pitch = collect_pitch_min
			_pitch_direction = 1 

		_pitch_reset_timer = collect_pitch_reset_time

func move():
	if input_dir == Vector2.ZERO or moving:
		return
	
	if input_dir.x != 0:
		anim.flip_h = (input_dir.x < 0)
	
	moving = true
	
	if step_sound != null:
		var audio = AudioStreamPlayer2D.new()
		audio.stream = step_sound
		audio.volume_db = step_volume
		audio.bus = "SFX"
		audio.global_position = global_position
		audio.pitch_scale = randf_range(step_pitch_min, step_pitch_max)
		get_parent().add_child(audio)
		audio.play()
		audio.finished.connect(audio.queue_free)
	
	var tween = create_tween()
	tween.tween_property(self, "position", position + input_dir * tile_size, TEMPO_DE_PASSO)
	tween.tween_callback(move_false)

	var squash_tween = create_tween()
	squash_tween.tween_property(anim, "scale", Vector2(1.6, 0.6), TEMPO_ANIMACAO / 2.0)
	squash_tween.tween_property(anim, "scale", Vector2(1.0, 1.0), TEMPO_ANIMACAO / 2.0)

func move_false():
	moving = false

func take_damage(amount):
	if invulneravel or $DamageTick.time_left > 0 or Constantes.JOGADOR_IMORTAL:
		return
	
	health -= amount
	health_changed.emit(health)
	if health <= 0:
		health = 0
		morrer()
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
		audio.bus = "SFX"
		audio.global_position = global_position
		audio.pitch_scale = randf_range(hurt_pitch_min, hurt_pitch_max)
		get_parent().add_child(audio)
		audio.play()
		audio.finished.connect(audio.queue_free)
		
	play_damage_effect()

func _on_self_damage_body_entered(body: Node2D) -> void:
	if "damage" in body: take_damage(body.damage)
	if body.has_method("apply_knockback"):
		var knockback_dir = global_position.direction_to(body.global_position)
		body.apply_knockback(touch_knockback_multiplier, knockback_dir)

func _on_damage_tick_timeout() -> void:
	modulate.a = 1
	
	if health > 0:
		anim.play("default")

func play_damage_effect() -> void:
	shake_screen(6.0) 
	
	if not Constantes.USAR_EFEITOS_TELA:
		return

	var tela_sangue = get_tree().get_first_node_in_group("EfeitoSangue")
	if tela_sangue == null or tela_sangue.material == null:
		return
		
	var mat = tela_sangue.material as ShaderMaterial
	var intensidade_maxima = lerp(0.8, 0.2, 0.6)
	
	var tween = create_tween()
	tween.tween_method(
		func(valor: float): mat.set_shader_parameter("sangue_intensidade", valor),
		0.0, intensidade_maxima, 0.1
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	tween.tween_method(
		func(valor: float): mat.set_shader_parameter("sangue_intensidade", valor),
		intensidade_maxima, 0.0, 0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func shake_screen(intensidade: float) -> void:
	if Constantes.USAR_SHAKE:
		var camera = $Camera2D
		if camera == null: return
		var tween = create_tween()
		for i in range(5):
			var deslocamento = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * intensidade
			tween.tween_property(camera, "offset", deslocamento, 0.04)
			intensidade *= 0.7 
		tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)
		
func feedback_erro_comando():
	if ERROR_FEEDBACK != null:
		var erro_inst = ERROR_FEEDBACK.instantiate()
		
		var pos_aleatoria = Vector2(randf_range(-15, 15), -40 + randf_range(-10, 10))
		erro_inst.global_position = global_position + pos_aleatoria
		
		get_parent().add_child(erro_inst)
		erro_inst.setup()

func configurar_modo_labirinto(recurso: ItemData) -> void:
	var camera = get_node_or_null("Camera2D")
	if camera:
		camera.position_smoothing_enabled = false
		camera.reset_smoothing()
		
	if ui_barra_vida: 
		ui_barra_vida.hide()
		
	if ui_recurso_labirinto:
		ui_recurso_labirinto.show()
		if ui_recurso_labirinto.has_method("setup"):
			ui_recurso_labirinto.setup(recurso)

func configurar_modo_arena() -> void:
	if ui_barra_vida: 
		ui_barra_vida.show()
		
	if ui_recurso_labirinto: 
		ui_recurso_labirinto.hide()

func configurar_modo_tutorial() -> void:
	if ui_barra_vida: 
		ui_barra_vida.hide()
		
	if ui_recurso_labirinto: 
		ui_recurso_labirinto.hide()

func _tocar_som_go(stream: AudioStream, volume: float):
	if stream == null: return
	var audio = AudioStreamPlayer.new()
	audio.stream = stream
	audio.volume_db = volume
	audio.bus = "UI"
	add_child(audio)
	audio.play()
	audio.finished.connect(audio.queue_free)

func morrer():
	invulneravel = true
	set_physics_process(false)
	input_dir = Vector2.ZERO

	var terminal = get_tree().get_first_node_in_group("Terminal")
	if terminal:
		terminal.set("bloqueio_game_over", true)
		if terminal.interpretador and terminal.interpretador.has_method("PararExecucao"):
			terminal.interpretador.PararExecucao()
		terminal.codigo_rodando = false
		terminal.limpar_destaque_execucao()
		terminal.atualizar_estado_botao()
		terminal.atualizar_travas_da_interface()

	get_tree().call_group("Enemy", "set_physics_process", false)
	if GerenciadorAudio.has_method("parar_musica"):
		GerenciadorAudio.parar_musica()

	var tela_morte = get_tree().root.find_child("TelaMorte", true, false)
	var iris = get_tree().root.find_child("IrisRect", true, false)
	var texto_morte = get_tree().root.find_child("TextoMorte", true, false)
	if not texto_morte: texto_morte = get_tree().root.find_child("TextoGameOver", true, false)
	
	var efeitos_go = get_tree().root.find_child("EfeitosGameOver", true, false)
	if efeitos_go: efeitos_go.hide()

	var mat = null
	if iris and iris.material:
		mat = iris.material as ShaderMaterial
		mat.set_shader_parameter("circle_size", 1.05)

	if tela_morte: tela_morte.show()
	if texto_morte: texto_morte.modulate.a = 0.0

	_tocar_som_go(go_som_foco, go_volume_foco)

	var tw_fase1 = create_tween().set_parallel(true)
	var camera = get_node_or_null("Camera2D")
	if camera:
		tw_fase1.tween_property(camera, "zoom", go_escala_zoom, go_tempo_zoom_iris).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if mat:
		tw_fase1.tween_method(func(v): mat.set_shader_parameter("circle_size", v), 1.05, go_tamanho_iris_foco, go_tempo_zoom_iris)

	await tw_fase1.finished

	if anim.sprite_frames.has_animation("morte"):
		anim.play("morte")
		await anim.animation_finished
	else:
		await get_tree().create_timer(1.0).timeout

	_tocar_som_go(go_som_fechar_iris, go_volume_fechar_iris)

	if mat:
		var tw_fase3 = create_tween()
		tw_fase3.tween_method(func(v): mat.set_shader_parameter("circle_size", v), go_tamanho_iris_foco, 0.0, go_tempo_fechar_iris)
		await tw_fase3.finished

	if efeitos_go: efeitos_go.show()

	_tocar_som_go(go_som_texto, go_volume_som_texto)

	if texto_morte:
		var tw_fase4 = create_tween()
		tw_fase4.tween_property(texto_morte, "modulate:a", 1.0, go_tempo_fade_texto)
		await tw_fase4.finished

	await get_tree().create_timer(go_tempo_espera_final).timeout

	var mundo = get_parent()
	if mundo and "recursos_iniciais" in mundo:
		RecursosManager.aplicarListaRecursos(mundo.recursos_iniciais)

	if terminal:
		terminal.set("bloqueio_game_over", false)
		terminal.abortar_arena()
		if terminal.has_method("iniciar_cooldown_seguranca"):
			terminal.iniciar_cooldown_seguranca()

	await get_tree().create_timer(1.2).timeout

	if efeitos_go: efeitos_go.hide()
	if is_instance_valid(tela_morte):
		tela_morte.hide()
	if mat:
		mat.set_shader_parameter("circle_size", 1.05)
