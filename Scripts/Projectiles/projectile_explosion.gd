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

var raio_explosao : float = 100.0
var tempo_visual : float = 1.0

var usar_textura_para_explosao : bool = false
var cor_explosao : Color = Color(1.0, 1.0, 1.0, 0.5)
var animacao_explosao : SpriteFrames

var usar_luz_na_explosao : bool = false
var luz_cor : Color
var luz_energia : float
var luz_tempo_fade : float
var luz_textura : Texture2D
var luz_multiplicador_area : float = 1.0

var tempo_de_vida : float = 5.0
var explodiu : bool = false

func _physics_process(delta: float) -> void:
	if explodiu: return
	
	position += direction * speed * delta
	tempo_de_vida -= delta
	if tempo_de_vida <= 0: queue_free()

func _on_body_entered(body: Node2D) -> void:
	if explodiu: return
	if body.is_in_group("Enemy"): detonar(body)

func detonar(alvo: Node2D = null) -> void:
	explodiu = true
	
	if alvo != null and is_instance_valid(alvo):
		global_position = alvo.global_position
	
	var intensidade_shake = remap(raio_explosao, 20.0, 100.0, 2.0, 8.0)
	intensidade_shake = clampf(intensidade_shake, 2.0, 8.0)
	var player = get_tree().get_first_node_in_group("Player")
	if player != null and player.has_method("shake_screen"):
		player.shake_screen(intensidade_shake)
	
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

	if usar_luz_na_explosao and luz_textura != null and Constantes.GRÁFICO_HIGH:
		var nova_luz = PointLight2D.new()
		nova_luz.texture = luz_textura
		nova_luz.color = luz_cor
		nova_luz.energy = luz_energia
		
		var largura_tex = luz_textura.get_width()
		var escala_luz = ((raio_explosao * 2.0) / float(largura_tex)) * luz_multiplicador_area
		nova_luz.texture_scale = escala_luz
		
		add_child(nova_luz)
		
		var light_tween = create_tween()
		light_tween.tween_property(nova_luz, "energy", 0.0, luz_tempo_fade)
		light_tween.tween_callback(nova_luz.queue_free)
		
	var raio_de_dano_real = raio_explosao * MULTIPLICADOR_DE_HITBOX
	var inimigos = get_tree().get_nodes_in_group("Enemy")
	for inimigo in inimigos:
		if is_instance_valid(inimigo):
			var dist = global_position.distance_to(inimigo.global_position)
			if dist <= raio_de_dano_real:
				var kb_dir = global_position.direction_to(inimigo.global_position)
				if kb_dir == Vector2.ZERO:
					kb_dir = direction
				if inimigo.has_method("take_damage"):
					inimigo.take_damage(damage, knockback_multiplier, kb_dir, ataque_nome)
					
	for child in get_children():
		if child.has_method("dissipar"):
			child.dissipar()
		elif child is CanvasItem:
			child.visible = false
			
	if usar_textura_para_explosao and animacao_explosao != null:
		var anim_node = AnimatedSprite2D.new()
		anim_node.sprite_frames = animacao_explosao
		
		if animacao_explosao.get_frame_count("default") > 0:
			var textura = animacao_explosao.get_frame_texture("default", 0)
			if textura != null:
				var largura = textura.get_width()
				var escala_necessaria = (raio_explosao * 2.0) / float(largura)
				anim_node.scale = Vector2(escala_necessaria, escala_necessaria)
				
		add_child(anim_node)
		anim_node.global_rotation = 0.0
		anim_node.play("default")
	else:
		queue_redraw()
		
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, tempo_visual)
	tween.tween_callback(queue_free)

func _draw() -> void:
	if explodiu and not usar_textura_para_explosao:
		draw_circle(Vector2.ZERO, raio_explosao, cor_explosao)
