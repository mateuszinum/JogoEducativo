extends Area2D

@export var direction : Vector2 = Vector2.RIGHT
@export var speed : float = 200.0
@export var damage : float = 1.0

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free() # Destrói o projétil ao acertar o inimigo

# Saiu da tela: pra nao voar infinitamente ele exclui o projetil
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	await get_tree().create_timer(1.0).timeout
	queue_free()
