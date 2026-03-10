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
	
	var player: Node2D = get_node("/root/World/Player")

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
			
		velocity = direction * speed
		move_and_slide()
		return

	if use_navigation:
		nav_agent.target_position = player.global_position

		if nav_agent.is_navigation_finished():
			use_navigation = false
			return

		var next_pos = nav_agent.get_next_path_position()
		var direction := (next_pos - global_position).normalized()

		if direction.x != 0:
			$AnimatedSprite2D.flip_h = (direction.x < 0)

		velocity = direction * speed
		move_and_slide()

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
