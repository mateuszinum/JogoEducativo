extends CharacterBody2D

const DAMAGE_NUMBER = preload("res://Scenes/Polimento/damage_number.tscn")
const CENA_BASE_DO_DROP = preload("res://Scenes/Drops/drop.tscn") 

const KNOCKBACK_FORCE : float = 400.0
const DISTANCIA_DESPAWN : float = 300.0

# --- CONSTANTES E VARIÁVEIS DE GELO ---
const TEMPO_CONGELAMENTO : float = 2.0
var timer_congelamento : float = 0.0
var is_frozen : bool = false
# --------------------------------------------

var speed: float = 60
var despawns: bool = true
@export var nav_agent: NavigationAgent2D

var invulneravel: bool = false
var spawner_ref: Node = null
var animacao_dano: Tween
var ultimo_ataque_recebido: String = ""

var knockback : Vector2
var separation : float

var path_timer : float = 0.0
var path_update_interval : float = 0.2 

var type : Enemy:
	set(value):
		type = value
		if value.animations != null:
			$AnimatedSprite2D.sprite_frames = value.animations
			$AnimatedSprite2D.play("default")
			
		health = value.health
		damage = value.damage
		speed = value.speed * 6.0
		despawns = value.despawns

var health : float:
	set(value):
		health = value
		if health <= 0:
			gerar_drops()
			queue_free()

var damage : float:
	set(value):
		damage = value

func _ready():
	nav_agent.path_desired_distance = 4
	nav_agent.target_desired_distance = 4
	
	path_timer = randf_range(0.0, 0.2)
	path_update_interval = randf_range(0.2, 0.3)
	
	spawner_ref = get_tree().get_first_node_in_group("Spawner")

func _physics_process(delta):
	check_separation(delta)
	
	if is_frozen:
		timer_congelamento -= delta
		if timer_congelamento <= 0.0:
			_descongelar()
	
	if knockback != Vector2.ZERO:
		knockback = knockback.lerp(Vector2.ZERO, 10 * delta)
	
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return

	path_timer -= delta
	if path_timer <= 0.0:
		nav_agent.target_position = player.global_position
		path_timer = path_update_interval 

	var direction := Vector2.ZERO
	if not nav_agent.is_navigation_finished() and nav_agent.is_target_reachable():
		var next_pos = nav_agent.get_next_path_position()
		direction = global_position.direction_to(next_pos)

		if direction.x != 0 and not is_frozen:
			$AnimatedSprite2D.flip_h = (direction.x < 0)

	var velocidade_movimento = direction * speed
	if is_frozen:
		velocidade_movimento = Vector2.ZERO
		
	velocity = velocidade_movimento + knockback
	
	_processar_comportamentos_especiais()
	move_and_slide()
	handle_enemy_collisions(delta)

func handle_enemy_collisions(delta):
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.is_in_group("Enemy"):
			if knockback.length() > 50:
				var push_dir = global_position.direction_to(collider.global_position)
				collider.apply_chain_knockback(push_dir * knockback.length() * 0.8)
			
			var repel_dir = collider.global_position.direction_to(global_position)
			knockback += repel_dir * 400 * delta

func check_separation(_delta):
	if !despawns: return
	var player = get_tree().get_first_node_in_group("Player")
	if player == null: return
		
	separation = (player.global_position - global_position).length()
	if separation >= DISTANCIA_DESPAWN:
		queue_free()

func take_damage(amount: float, kb_mult: float = 1.0, knockback_dir: Vector2 = Vector2.ZERO, ataque_nome: String = ""):
	if invulneravel:
		if kb_mult > 0.0 and knockback_dir != Vector2.ZERO:
			apply_knockback(kb_mult, knockback_dir)
		return
	
	ultimo_ataque_recebido = ataque_nome
	
	var mult = 1.0
	var is_slime_gelo = false
	
	if type != null:
		if type.nome == "SlimeDeGelo":
			is_slime_gelo = true
			
		if ataque_nome != "":
			for weak in type.multiplicadores_de_ataque:
				if weak.ataque != null and "nome" in weak.ataque and weak.ataque.nome == ataque_nome:
					mult = weak.multiplicador
					break
	
	var final_damage = amount * mult
	health -= final_damage
	show_damage_number(final_damage)
	
	# Verifica se congela e PAUSA a animação 
	if (ataque_nome == "Gelo" or ataque_nome == "ExplosaoGelo") and not is_slime_gelo:
		if not is_frozen:
			$AnimatedSprite2D.pause()
		is_frozen = true
		timer_congelamento = TEMPO_CONGELAMENTO
	
	_aplicar_flash_dano()
	
	if kb_mult > 0.0 and knockback_dir != Vector2.ZERO:
		apply_knockback(kb_mult, knockback_dir)
	
func apply_knockback(mult: float, knockback_dir: Vector2):
	var globalMult = Atributos.global_knockback_multiplier
	knockback = knockback_dir * KNOCKBACK_FORCE * mult * globalMult

func _aplicar_flash_dano():
	if animacao_dano and animacao_dano.is_valid():
		animacao_dano.kill()
		
	animacao_dano = create_tween()
	
	if is_frozen:
		$AnimatedSprite2D.modulate = Color(0.8, 0.9, 1.0) 
		animacao_dano.tween_property($AnimatedSprite2D, "modulate", Color(0.4, 0.7, 1.0), 0.2)
	else:
		$AnimatedSprite2D.modulate = Color.RED
		animacao_dano.tween_property($AnimatedSprite2D, "modulate", Color.WHITE, 0.2)
		
	animacao_dano.tween_callback(_atualizar_visual)

# Retoma a animação ao descongelar 
func _descongelar():
	is_frozen = false
	$AnimatedSprite2D.play() 
	if animacao_dano and animacao_dano.is_valid():
		animacao_dano.kill()
		
	animacao_dano = create_tween()
	animacao_dano.tween_property($AnimatedSprite2D, "modulate", Color.WHITE, 0.15)
	animacao_dano.tween_callback(_atualizar_visual)

func apply_chain_knockback(force: Vector2):
	if force.length() > knockback.length():
		knockback = force

func show_damage_number(amount):
	var dmg_num = DAMAGE_NUMBER.instantiate()
	dmg_num.global_position = global_position
	dmg_num.global_position.x += randf_range(-12, 12)
	dmg_num.global_position.y += randf_range(-12, 12)
	get_parent().add_child(dmg_num)
	dmg_num.setup(amount)
	
func gerar_drops() -> void:
	var multiplicador = 1
	if ultimo_ataque_recebido == "FeixeLuz":
		multiplicador = 2
	
	if type != null and type.tabela_de_drops != null:
		for drop in type.tabela_de_drops:
			var sorteio = randf() * 100.0 
			if sorteio <= drop.chance_de_drop:
				var min_seguro = drop.quantidade_minima
				var max_seguro = max(min_seguro, drop.quantidade_maxima)
				var qtd_sorteada = randi_range(min_seguro, max_seguro)
				qtd_sorteada = qtd_sorteada * multiplicador
				for i in range(qtd_sorteada):
					var novo_drop = CENA_BASE_DO_DROP.instantiate()
					novo_drop.configurar(drop.item, 1)
					novo_drop.global_position = global_position
					get_parent().call_deferred("add_child", novo_drop)

func _atualizar_visual() -> void:
	if type == null: return
	
	if is_frozen:
		$AnimatedSprite2D.modulate = Color(0.4, 0.7, 1.0)
	else:
		$AnimatedSprite2D.modulate = Color.WHITE
	
	match type.comportamento_especial:
		Enemy.Comportamento.FANTASMA:
			if invulneravel:
				$AnimatedSprite2D.modulate.a = type.fantasma_alpha_translucido
			else:
				$AnimatedSprite2D.modulate.a = type.fantasma_alpha_solido
		_:
			$AnimatedSprite2D.modulate.a = 1.0

func _processar_comportamentos_especiais():
	if type == null: return
	match type.comportamento_especial:
		Enemy.Comportamento.FANTASMA: _comportamento_fantasma()

func _comportamento_fantasma():
	if not is_instance_valid(spawner_ref): return
	
	var tempo_global = spawner_ref.total_time_seconds
	var tempo_solido = type.fantasma_tempo_solido
	var tempo_trans = type.fantasma_tempo_translucido
	var tempo_ciclo = tempo_solido + tempo_trans
	
	if tempo_ciclo <= 0: return
	
	var tempo_atual_no_ciclo = fmod(tempo_global, tempo_ciclo)
	var fase_fantasma = tempo_atual_no_ciclo >= tempo_solido
	
	if fase_fantasma != invulneravel:
		invulneravel = fase_fantasma
		
		if invulneravel and animacao_dano and animacao_dano.is_valid():
			animacao_dano.kill()
			
		_atualizar_visual()
		
		if invulneravel:
			set_collision_mask_value(1, false)
			set_collision_mask_value(2, false)
		else:
			set_collision_mask_value(1, true)
			set_collision_mask_value(2, true)
