extends CPUParticles2D

@export_group("Configuracoes Iniciais")
@export var cor_rastro : Color = Color(1.0, 1.0, 1.0, 0.8)
@export var quantidade : int = 50
@export var tempo_vida : float = 0.4
@export var tamanho_inicial : float = 1.0
@export var tamanho_final : float = 0.0

@export_group("Movimento")
@export var gravidade : Vector2 = Vector2.ZERO
@export var espalhamento : float = 15.0

var _morrendo : bool = false

func _ready() -> void:
	if not Constantes.GRÁFICO_HIGH:
		queue_free()
		return
		
	color = cor_rastro
	amount = quantidade
	lifetime = tempo_vida
	gravity = gravidade
	spread = espalhamento
	
	if scale_amount_curve == null:
		var curve = Curve.new()
		curve.add_point(Vector2(0, tamanho_inicial))
		curve.add_point(Vector2(1, tamanho_final))
		scale_amount_curve = curve

func dissipar() -> void:
	if _morrendo: return
	_morrendo = true
	
	emitting = false
	
	var pos_global = global_position
	var cena_atual = get_tree().current_scene 
	
	get_parent().remove_child(self)
	cena_atual.add_child(self)
	global_position = pos_global
	
	await get_tree().create_timer(lifetime).timeout
	queue_free()
