extends Area2D

const MULTIPLICADOR_DE_HITBOX : float = 1.25

var direction : Vector2 = Vector2.RIGHT
var speed : float = 200.0
var damage : float = 1.0
var knockback_multiplier : float = 1.0
var ataque_nome : String = "" 

var hit_sound : AudioStream
var hit_volume : float = 0.0
var pitch_min : float = 0.8
var pitch_max : float = 1.2

# Recebidos automaticamente do recurso AtaqueEmArea
var raio_explosao : float = 100.0
var tempo_visual : float = 1.0
var cor_explosao : Color = Color(1.0, 1.0, 1.0, 0.5) # Branco Translúcido por padrão

var tempo_de_vida : float = 5.0
var explodiu : bool = false

func _physics_process(delta: float) -> void:
	if explodiu: return # Trava o projétil no lugar
	
	position += direction * speed * delta
	tempo_de_vida -= delta
	if tempo_de_vida <= 0: queue_free()

func _on_body_entered(body: Node2D) -> void:
	if explodiu: return
	# Passa a referência do inimigo atingido para a função detonar
	if body.is_in_group("Enemy"): detonar(body)

func detonar(alvo: Node2D = null) -> void:
	explodiu = true
	
	# Centraliza o projétil exatamente na origem do inimigo atingido
	if alvo != null and is_instance_valid(alvo):
		global_position = alvo.global_position
	
	var intensidade_shake = remap(raio_explosao, 20.0, 100.0, 2.0, 8.0)
	intensidade_shake = clampf(intensidade_shake, 2.0, 8.0)
	var player = get_tree().get_first_node_in_group("Player")
	if player != null and player.has_method("shake_screen"):
		player.shake_screen(intensidade_shake)
	
	# 1. ÁUDIO
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
		
	# 2. DANO EM ÁREA
	var raio_de_dano_real = raio_explosao * MULTIPLICADOR_DE_HITBOX
	
	var inimigos = get_tree().get_nodes_in_group("Enemy")
	for inimigo in inimigos:
		if is_instance_valid(inimigo):
			var dist = global_position.distance_to(inimigo.global_position)
			
			if dist <= raio_de_dano_real:
				var kb_dir = global_position.direction_to(inimigo.global_position)
				
				# CORREÇÃO DO KNOCKBACK: 
				# Se o inimigo for o alvo central, a direção será (0,0).
				# Nesse caso, o empurrão segue a direção original de voo da magia!
				if kb_dir == Vector2.ZERO:
					kb_dir = direction
					
				if inimigo.has_method("take_damage"):
					inimigo.take_damage(damage, knockback_multiplier, kb_dir, ataque_nome)
					
	# 3. Limpa visual do projétil
	for child in get_children():
		if child is CanvasItem: 
			child.visible = false
			
	# 4. FEEDBACK VISUAL
	queue_redraw()
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, tempo_visual)
	tween.tween_callback(queue_free)

func _draw() -> void:
	if explodiu:
		# Desenha um círculo preenchido no centro com o raio exato da hitbox
		draw_circle(Vector2.ZERO, raio_explosao, cor_explosao)
