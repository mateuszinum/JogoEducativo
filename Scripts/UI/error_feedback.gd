extends Node2D

# --- CONFIGURAÇÕES DA ANIMAÇÃO ---
const OFFSET_MAX_X : float = 10.0
const OFFSET_MAX_Y : float = 16.0
const ALTURA_PULO  : float = 15.0
const DURACAO      : float = 0.4
const ESCALA_POP   : float = 1.5
const FADE_DELAY   : float = 0.2

# --- CONFIGURAÇÕES DE ÁUDIO ---
const PITCH_MIN    : float = 0.8  # Som mais grave/lento
const PITCH_MAX    : float = 1.2  # Som mais agudo/rápido

@export_group("Audio")
@export var som_erro : AudioStream
@export var volume_erro : float = 0.0

@onready var label = $Label

func setup():
	# 1. Toca o som universal de erro com Pitch Aleatório
	if som_erro != null:
		var audio = AudioStreamPlayer.new()
		audio.stream = som_erro
		audio.volume_db = volume_erro
		audio.bus = "UI"
		
		# Define o pitch aleatório dentro da range configurada
		audio.pitch_scale = randf_range(PITCH_MIN, PITCH_MAX)
		
		add_child(audio)
		audio.play()
		audio.finished.connect(audio.queue_free)

	# 2. Aplica a variância de spawn
	var variancia = Vector2(
		randf_range(-OFFSET_MAX_X, OFFSET_MAX_X),
		randf_range(-OFFSET_MAX_Y, OFFSET_MAX_Y)
	)
	global_position += variancia

	# 3. Animação de pop e pulo
	label.pivot_offset = label.size / 2 
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y - ALTURA_PULO, DURACAO).set_ease(Tween.EASE_OUT)
	
	label.scale = Vector2(0.3, 0.3)
	tween.tween_property(label, "scale", Vector2(ESCALA_POP, ESCALA_POP), 0.1)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.1)
	
	tween.tween_property(self, "modulate:a", 0.0, 0.3).set_delay(FADE_DELAY)
	tween.chain().tween_callback(queue_free)
