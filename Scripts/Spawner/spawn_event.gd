extends Resource
class_name SpawnEvent

@export var time_in_seconds : int # O momento exato em que a regra muda (ex: 60)
@export var enemy_type : Enemy    # Qual inimigo vai ser alterado
@export var spawn_rate : float      # Quantidade a ser spawnada por segundo (0 = para de nascer)
