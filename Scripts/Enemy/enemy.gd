extends CharacterBody2D

const DAMAGE_NUMBER = preload("res://Scenes/UI/damage_number.tscn")
# --- PASSO 4: PRELOAD DA CENA DO DROP (ATUALIZE ESTE CAMINHO PARA A SUA CENA!) ---
const CENA_BASE_DO_DROP = preload("res://Scenes/Drops/drop.tscn") 

const KNOCKBACK_FORCE : float = 400.0
const DISTANCIA_DESPAWN : float = 300.0

var speed: float = 60
var despawns: bool = true
@export var nav_agent: NavigationAgent2D




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
			gerar_drops() #  CHAMA A FUNÇÃO DE DROPS ANTES DE MORRER 
			queue_free()

var damage : float:
	set(value):
		damage = value

func _ready():
	nav_agent.path_desired_distance = 4
	nav_agent.target_desired_distance = 4
	
	path_timer = randf_range(0.0, 0.2)
	path_update_interval = randf_range(0.2, 0.3)

func _physics_process(delta):
	check_separation(delta)
	
	if knockback != Vector2.ZERO:
		knockback = knockback.lerp(Vector2.ZERO, 10 * delta)
	
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return

	path_timer -= delta
	if path_timer <= 0.0:
		nav_agent.target_position = player.global_position
		path_timer = path_update_interval 

	if nav_agent.is_navigation_finished() or not nav_agent.is_target_reachable():
		return

	var next_pos = nav_agent.get_next_path_position()
	var direction := global_position.direction_to(next_pos)

	if direction.x != 0:
		$AnimatedSprite2D.flip_h = (direction.x < 0)

	velocity = (direction * speed) + knockback
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
	if !despawns:
		return
		
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return
		
	separation = (player.global_position - global_position).length()
	if separation >= DISTANCIA_DESPAWN:
		queue_free()

func take_damage(amount, mult = 1.0, knockback_dir: Vector2 = Vector2.ZERO, ataque_nome: String = ""):
	var dano_final = amount
	
	if type != null:
		var mult_elemento = 1.0 
		
		if type.multiplicadores_de_ataque != null:
			for fraqueza in type.multiplicadores_de_ataque:
				if fraqueza.ataque != null and fraqueza.ataque.nome == ataque_nome:
					mult_elemento = fraqueza.multiplicador
					break
		dano_final *= mult_elemento
		
	health -= dano_final
	apply_knockback(mult, knockback_dir)
	show_damage_number(dano_final)
	
func apply_knockback(mult, knockback_dir: Vector2 = Vector2.ZERO):
	var player = get_tree().get_first_node_in_group("Player")
	var globalMult = 1.0
	
	if player != null:
		globalMult = Atributos.global_knockback_multiplier
	
	knockback = knockback_dir * KNOCKBACK_FORCE * mult * globalMult
	
	$AnimatedSprite2D.modulate = Color.RED
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "modulate", Color.WHITE, 0.2)

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
	print("--- LOG DE DROP ---")
	print("1. Inimigo morreu. Iniciando gerar_drops().")
	
	if type != null:
		print("2. Inimigo possui o type: ", type.nome)
		
		if type.tabela_de_drops != null and type.tabela_de_drops.size() > 0:
			print("3. Tabela de drops encontrada com ", type.tabela_de_drops.size(), " itens.")
			
			for drop in type.tabela_de_drops:
				var sorteio = randf() * 100.0 
				
				if sorteio <= drop.chance_de_drop:
					var min_seguro = drop.quantidade_minima
					var max_seguro = max(min_seguro, drop.quantidade_maxima)
					var qtd_sorteada = randi_range(min_seguro, max_seguro)
					for i in range(qtd_sorteada):
						var novo_drop = CENA_BASE_DO_DROP.instantiate()
						novo_drop.configurar(drop.item, 1)
						novo_drop.global_position = global_position
						get_parent().call_deferred("add_child", novo_drop)
