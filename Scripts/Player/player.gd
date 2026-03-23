extends CharacterBody2D

const OPACIDADE_NO_DANO : float = 1.0

@onready var anim = $AnimatedSprite2D
signal health_changed(current_health)

@export var health = 50
@export var max_health = health
@export var touch_knockback_multiplier: float = 1.0
@export var global_knockback_multiplier: float = 1.0

@export_group("Audio")
@export var hurt_sound : AudioStream
@export var hurt_volume : float = 0.0
@export var hurt_pitch_min : float = 0.8
@export var hurt_pitch_max : float = 1.2
@export var step_sound : AudioStream
@export var step_volume : float = 0.0
@export var step_pitch_min : float = 0.8
@export var step_pitch_max : float = 1.2

const tile_size = 32
var moving : bool = false
var input_dir

@export_group("Inventory")
@export var inventario_armas : Array[Weapon] = []
var indice_arma_atual : int = 0
var arma_equipada : Weapon = null

var enemies_in_range : Array[CharacterBody2D] = []
var nearest_enemy : CharacterBody2D = null

func _ready() -> void:
	anim.play("default")
	if inventario_armas.size() > 0:
		arma_equipada = inventario_armas[0]
		%WeaponSlot.weapon = arma_equipada
		
func trocar_arma() -> void:
	if inventario_armas.is_empty():
		return
		
	indice_arma_atual += 1
	if indice_arma_atual >= inventario_armas.size():
		indice_arma_atual = 0
		
	arma_equipada = inventario_armas[indice_arma_atual]
	%WeaponSlot.weapon = arma_equipada 

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("change_weapon"):
		trocar_arma()
		
	input_dir = Vector2.ZERO

	var dirs = {
		"move_up":    Vector2.UP,
		"move_down":  Vector2.DOWN,
		"move_left":  Vector2.LEFT,
		"move_right": Vector2.RIGHT
	}

	for action in dirs:
		if Input.is_action_just_pressed(action):
			input_dir = dirs[action]
			move()
			break

func move():
	if input_dir == Vector2.ZERO or moving:
		return

	$RayCast2D.target_position = input_dir * tile_size
	$RayCast2D.force_raycast_update()

	if $RayCast2D.is_colliding():
		return 
	
	if input_dir.x != 0:
		anim.flip_h = (input_dir.x < 0)
	
	moving = true
	
	if step_sound != null:
		var audio = AudioStreamPlayer2D.new()
		audio.stream = step_sound
		audio.volume_db = step_volume
		audio.global_position = global_position
		audio.pitch_scale = randf_range(step_pitch_min, step_pitch_max)
		get_parent().add_child(audio)
		audio.play()
		audio.finished.connect(audio.queue_free)
	
	var tween = create_tween()
	tween.tween_property(self, "position", position + input_dir * tile_size, 0.05)
	tween.tween_callback(move_false)

	var squash_tween = create_tween()
	squash_tween.tween_property(anim, "scale", Vector2(1.6, 0.6), 0.025)
	squash_tween.tween_property(anim, "scale", Vector2(1.0, 1.0), 0.025)

func move_false():
	moving = false
	
func take_damage(amount):
	if $DamageTick.time_left > 0:
		return
	
	health -= amount
	health_changed.emit(health)
	
	$DamageTick.start()
	
	modulate.a = OPACIDADE_NO_DANO
	
	anim.modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(anim, "modulate", Color.WHITE, 0.2)
	
	anim.play("hurt")
	
	if hurt_sound != null:
		var audio = AudioStreamPlayer2D.new()
		audio.stream = hurt_sound
		audio.volume_db = hurt_volume
		audio.global_position = global_position
		audio.pitch_scale = randf_range(hurt_pitch_min, hurt_pitch_max)
		get_parent().add_child(audio)
		audio.play()
		audio.finished.connect(audio.queue_free)

func _on_enemy_detector_body_entered(body):
	if body.is_in_group("Enemy"):
		enemies_in_range.append(body)

func _on_enemy_detector_body_exited(body):
	enemies_in_range.erase(body)

func _on_nearest_enemy_timer_timeout():
	if enemies_in_range.size() > 0:
		nearest_enemy = InimigoMaisProximo.get_nearest_enemy(global_position, enemies_in_range)
	else:
		nearest_enemy = null
	
func _on_self_damage_body_entered(body: Node2D) -> void:
	if "damage" in body:
		take_damage(body.damage)
	
	if body.has_method("apply_knockback"):
		var knockback_dir = global_position.direction_to(body.global_position)
		body.apply_knockback(touch_knockback_multiplier, knockback_dir)

func _on_damage_tick_timeout() -> void:
	modulate.a = 1
	anim.play("default")
