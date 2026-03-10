extends CharacterBody2D

const DAMAGE_NUMBER = preload("res://Scenes/UI/damage_number.tscn")
const KNOCKBACK_FORCE : float = 400.0

@export var player_reference : CharacterBody2D
var speed: float = 60
var despawns: bool = true
@export var nav_agent: NavigationAgent2D

var knockback : Vector2
var separation : float
var use_navigation := false

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
			queue_free()

var damage : float:
	set(value):
		damage = value

func _ready():
	nav_agent.path_desired_distance = 4
	nav_agent.target_desired_distance = 4

func _physics_process(delta):
	check_separation(delta)
	
	if knockback != Vector2.ZERO:
		knockback = knockback.lerp(Vector2.ZERO, 10 * delta)
	
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
			
		velocity = (direction * speed) + knockback
		move_and_slide()
		handle_enemy_collisions(delta)
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

		velocity = (direction * speed) + knockback
		move_and_slide()
		handle_enemy_collisions(delta)

		$RayCast2D.force_raycast_update()
		if not $RayCast2D.is_colliding():
			use_navigation = false

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
		
	separation = (player_reference.position - position).length()
	if separation >= 500:
		queue_free()

func take_damage(amount, mult = 1.0, knockback_dir: Vector2 = Vector2.ZERO):
	health -= amount
	apply_knockback(mult, knockback_dir)
	show_damage_number(amount)
	
func apply_knockback(mult, knockback_dir: Vector2 = Vector2.ZERO):
	var player: Node2D = get_node("/root/World/Player")
	var globalMult = player.global_knockback_multiplier
	
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
	get_tree().current_scene.add_child(dmg_num)
	dmg_num.setup(amount)
