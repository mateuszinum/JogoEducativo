extends CharacterBody2D

const DAMAGE_NUMBER = preload("res://Scenes/UI/damage_number.tscn")
const KNOCKBACK_FORCE : float = 200.0

@export var player_reference : CharacterBody2D
@export var speed: float = 60
@export var nav_agent: NavigationAgent2D

var knockback : Vector2
var separation : float
var use_navigation := false  # Troca entre modos de navegação

var type : Enemy:
	set(value):
		type = value
		if value.animations != null:
			$AnimatedSprite2D.sprite_frames = value.animations
			$AnimatedSprite2D.play("default")
			
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
	
	# Faz a força do knockback diminuir suavemente até zero ao longo do tempo (Fricção)
	if knockback != Vector2.ZERO:
		knockback = knockback.lerp(Vector2.ZERO, 10 * delta)
	
	var player: Node2D = get_node("/root/World/Player")

	# Modo 1: Seguir Player
	if not use_navigation:
		var direction := global_position.direction_to(player.global_position)

		if direction.x != 0:
			$AnimatedSprite2D.flip_h = (direction.x < 0)

		$RayCast2D.target_position = direction * 64
		$RayCast2D.force_raycast_update()

		if $RayCast2D.is_colliding():
			use_navigation = true
			nav_agent.target_position = player.global_position
			return
			
		# Adicionamos o knockback na velocidade final 
		velocity = (direction * speed) + knockback
		move_and_slide()
		return

	# Modo 2: Navegar até o Player
	if use_navigation:
		nav_agent.target_position = player.global_position

		if nav_agent.is_navigation_finished():
			use_navigation = false
			return

		var next_pos = nav_agent.get_next_path_position()
		var direction := (next_pos - global_position).normalized()

		if direction.x != 0:
			$AnimatedSprite2D.flip_h = (direction.x < 0)

		# Adicionamos o knockback na velocidade final aqui também 
		velocity = (direction * speed) + knockback
		move_and_slide()

		$RayCast2D.force_raycast_update()
		if not $RayCast2D.is_colliding():
			use_navigation = false

func check_separation(_delta):
	separation = (player_reference.position - position).length()
	# No futuro, colocar para NÃO deletar bosses
	if separation >= 500:
		queue_free()

func take_damage(amount, knockback_dir: Vector2 = Vector2.ZERO):
	health -= amount

	apply_knockback(knockback_dir)
	show_damage_number(amount)
	
func apply_knockback(knockback_dir: Vector2 = Vector2.ZERO):
	knockback = knockback_dir * KNOCKBACK_FORCE
	$AnimatedSprite2D.modulate = Color.RED
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "modulate", Color.WHITE, 0.2)
	
func show_damage_number(amount):
	var dmg_num = DAMAGE_NUMBER.instantiate()
	dmg_num.global_position = global_position
	dmg_num.global_position.x += randf_range(-12, 12)
	dmg_num.global_position.y += randf_range(-12, 12)
	get_tree().current_scene.add_child(dmg_num)
	dmg_num.setup(amount)
