extends Area2D

@export var direction : Vector2 = Vector2.RIGHT
@export var speed : float = 200.0
@export var damage : float = 1.0
@export var pierce_enemies : bool = false
var knockback_multiplier : float = 1.0

var ataque_nome : String = "" 

var hit_sound : AudioStream
var hit_volume : float = 0.0
var pitch_min : float = 0.8
var pitch_max : float = 1.2

var tempo_de_vida : float = 1

var _inimigos_atingidos: Array[Node] = []

func destruir_com_estilo() -> void:
	for child in get_children():
		if child.has_method("dissipar"):
			child.dissipar()
	queue_free()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	tempo_de_vida -= delta
	if tempo_de_vida <= 0:
		destruir_com_estilo()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		if body in _inimigos_atingidos:
			return
			
		_inimigos_atingidos.append(body)
		
		body.take_damage(damage, knockback_multiplier, direction, ataque_nome)
		
		if hit_sound != null:
			var audio = AudioStreamPlayer2D.new()
			audio.stream = hit_sound
			audio.volume_db = hit_volume
			audio.bus = "SFX"
			audio.global_position = global_position
			audio.pitch_scale = randf_range(pitch_min, pitch_max)
			get_tree().current_scene.add_child(audio)
			audio.play()
			audio.finished.connect(audio.queue_free)
			
		if not pierce_enemies:
			queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
