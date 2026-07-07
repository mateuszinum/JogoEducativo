extends Node

signal xp_alterado(xp_atual: int, xp_necessario: int)
signal subiu_de_nivel(novo_nivel: int)
signal max_level_alcancado()

# ------------------------------------- #
# Constantes
const LEVEL_UP_XP : int = 10 # valor base de xp para subir de level (multiplicado pelo level_atual)
const MAX_LEVEL : int = 10 # level máximo que o player pode alcançar
const MAX_BONUS : float = 2.0 # valor máximo que o bônus pode assumir

# Atributos iniciais
var max_health : int = 5
var global_knockback_multiplier : float = 1.0
var tempo_tick : float = 0.8
var coleta_multiplier : float = 1.0
var forca_multiplier : float = 1.0

# Upgrades da bruxa
var ganhos_health = [7, 10, 15]
var ganhos_kb = [1.5, 2.0, 3.0]
var ganhos_agilidade = [0.7, 0.5, 0.3]
var ganhos_coleta = [2.0, 3.0, 4.0]
var ganhos_forca = [1.5, 2.0, 3.0]
# ------------------------------------- #


#--------------------------------------#
var incremento_bonus : float = 0.1
var range_bonus : float = 1.0

var level_atual : int = 1
var xp_atual : int = 0
var bonus_level : float = 1.0

func _ready() -> void:
	range_bonus = MAX_BONUS - 1.0
	incremento_bonus = range_bonus / MAX_LEVEL

func GetTempoTick():
	return tempo_tick / bonus_level

func comprar_upgrade(nome_upgrade, nivel_atual):
	match nome_upgrade:
		"Agilidade":
			var novo_valor = ganhos_agilidade[nivel_atual - 2]
	
			tempo_tick = novo_valor
			if Constantes.DEBUG: print("Upgrade Nível ", nivel_atual, "! Agilidade está em:", novo_valor)
		
		"Vida Máxima":
			var novo_valor = ganhos_health[nivel_atual - 2]
	
			max_health = novo_valor
			if Constantes.DEBUG: print("Upgrade Nível ", nivel_atual, "! Vida Máxima agora é ", novo_valor)
			
		"Knockback":
			var novo_valor = ganhos_kb[nivel_atual - 2]
	
			global_knockback_multiplier = novo_valor
			if Constantes.DEBUG: print("Upgrade Nível ", nivel_atual, "! Multiplicador de knockback está em: ", novo_valor, " x")
		
		"Coleta":
			var novo_valor = ganhos_coleta[nivel_atual - 2]
	
			coleta_multiplier = novo_valor
			if Constantes.DEBUG: print("Upgrade Nível ", nivel_atual, "! Multiplicador de Coleta está em: ", novo_valor, " x")
		
		"Força":
			var novo_valor = ganhos_forca[nivel_atual - 2]
			
			forca_multiplier = novo_valor
			if Constantes.DEBUG: print("Upgrade Nível ", nivel_atual, "! Multiplicador de Força está em: ", novo_valor, " x")

func maximizar_atributos() -> void:
	tempo_tick = ganhos_agilidade[-1]
	max_health = ganhos_health[-1]
	global_knockback_multiplier = ganhos_kb[-1]
	coleta_multiplier = ganhos_coleta[-1]
	forca_multiplier = ganhos_forca[-1]
	if Constantes.DEBUG: print("Os atributos foram maximizados!")

func duplicar_agilidade() -> void:
	tempo_tick = tempo_tick/2
	if Constantes.DEBUG: print("A agilidade foi duplicada!")

func debug_tempo_tick():
	if Constantes.DEBUG: print(GetTempoTick())
#--------------------------------------#


#--------------------------------------#
# SISTEMA DE BÔNUS (SUBIR DE NÍVEL)

func ganhar_xp(valor : int = 1):
	if level_atual >= MAX_LEVEL: return
	
	xp_atual = xp_atual + valor
	var xp_necessario = LEVEL_UP_XP * level_atual
	
	if xp_atual >= xp_necessario:
		subir_de_nivel()
		resetar_xp()
		xp_necessario = LEVEL_UP_XP * level_atual 
		
	xp_alterado.emit(xp_atual, xp_necessario)
	if Constantes.DEBUG: print("XP atual: ", xp_atual)

func subir_de_nivel():
	level_atual = level_atual + 1
	if Constantes.DEBUG: print("Nível atual: ", level_atual)
	incrementar_bonus()
	
	subiu_de_nivel.emit(level_atual)
	
	if level_atual >= MAX_LEVEL:
		max_level_alcancado.emit()

func incrementar_bonus():
	bonus_level = bonus_level + incremento_bonus
	if Constantes.DEBUG: print("Bônus atual: ", bonus_level)

func resetar_level():
	level_atual = 1

func resetar_bonus():
	bonus_level = 1.0

func resetar_xp():
	xp_atual = 0
	
func resetar_xp_bonus_level():
	resetar_bonus()
	resetar_level()
	resetar_xp()
#--------------------------------------#

func recalcular_atributos(produtos_salvos: Dictionary):
	max_health = 5
	global_knockback_multiplier = 1.0
	tempo_tick = 0.8
	coleta_multiplier = 1.0
	forca_multiplier = 1.0

	if produtos_salvos.get("agilidade", 1) >= 2:
		comprar_upgrade("Agilidade", produtos_salvos["agilidade"])
		
	if produtos_salvos.get("vida máxima", 1) >= 2:
		comprar_upgrade("Vida Máxima", produtos_salvos["vida máxima"])
		
	if produtos_salvos.get("knockback", 1) >= 2:
		comprar_upgrade("Knockback", produtos_salvos["knockback"])
		
	if produtos_salvos.get("coleta", 1) >= 2:
		comprar_upgrade("Coleta", produtos_salvos["coleta"])
		
	if produtos_salvos.get("força", 1) >= 2:
		comprar_upgrade("Força", produtos_salvos["força"])

func checar_atributos_maximos() -> void:
	if (tempo_tick == ganhos_agilidade[-1] and
		max_health == ganhos_health[-1] and
		global_knockback_multiplier == ganhos_kb[-1] and
		coleta_multiplier == ganhos_coleta[-1] and
		forca_multiplier == ganhos_forca[-1]):
		
		if has_node("/root/AchievementsManager"):
			AchievementsManager.unlock_achievement("MAX_ATRIBUTOS")
