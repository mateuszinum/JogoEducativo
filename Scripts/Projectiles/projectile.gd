extends Area2D

# O @export permite mudar esses valores no Inspector para cada projétil diferente!
@export var direction : Vector2 = Vector2.RIGHT
@export var speed : float = 200.0
@export var damage : float = 1.0

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free() # Destrói o projétil ao acertar o inimigo

#saiu da tela: pra nao voar infinitamente ele exclui o projetil
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# O código vai pausar nesta linha e esperar 1 segundos antes de excluir o projetil
	await get_tree().create_timer(1.0).timeout
	# Só depois de 2 segundos ele vem para a linha de baixo e destrói o tiro
	queue_free()
