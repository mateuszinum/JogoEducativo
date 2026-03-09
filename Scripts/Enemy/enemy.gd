extends CharacterBody2D

@export var player_reference : CharacterBody2D
@export var speed: float = 60
@export var nav_agent: NavigationAgent2D

var knockback : Vector2
var separation : float
var use_navigation := false  # Troca entre modos de navegação

var type : Enemy:
	set(value):
		type = value
		$Sprite2D.texture = value.texture
		health = value.health
		damage = value.damage

var health : float:
	set(value):
		health = value
		if health <= 0:
			queue_free()

var damage : float:
	set(value):
		damage = value

func _ready():
	nav_agent.path_desired_distance = 4
	nav_agent.target_desired_distance = 4

func _physics_process(delta):
	check_separation(delta)
	
	var player: Node2D = get_node("/root/World/Player")

	# Modo 1: Seguir Player
	if not use_navigation:
		var direction := global_position.direction_to(player.global_position)

		# Atualiza Raycast para olhar para frente
		$RayCast2D.target_position = direction * 64
		$RayCast2D.force_raycast_update()

		# Se encontra parede -> troca modo de navegação
		if $RayCast2D.is_colliding():
			use_navigation = true
			nav_agent.target_position = player.global_position
			return
			
		# Move diretamente para o player
		velocity = direction * speed
		move_and_slide()
		return

	# Modo 2: Navegar até o Player
	if use_navigation:
		# Sempre atualiza o target para ser o player
		nav_agent.target_position = player.global_position

		if nav_agent.is_navigation_finished():
			# Quando navegação acaba -> muda de volta para Modo 1
			use_navigation = false
			return

		var next_pos = nav_agent.get_next_path_position()
		var direction := (next_pos - global_position).normalized()

		velocity = direction * speed
		move_and_slide()

		# Se RayCast não encontra nada, volta para Modo 1
		$RayCast2D.force_raycast_update()
		if not $RayCast2D.is_colliding():
			use_navigation = false

func check_separation(_delta):
	separation = (player_reference.position - position).length()
	# No futuro, colocar para NÃO deletar bosses
	if separation >= 500:
		queue_free()

func take_damage(amount):
	health -= amount
