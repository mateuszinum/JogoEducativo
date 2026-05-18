extends Node

func listarConfig() -> Dictionary:
	var config = {
		"VOLUME_MASTER": Constantes.VOLUME_MASTER,
		"VOLUME_MUSICA": Constantes.VOLUME_MUSICA,
		"VOLUME_SFX": Constantes.VOLUME_SFX,
		"VOLUME_UI": Constantes.VOLUME_UI,
		"TELA_CHEIA": Constantes.TELA_CHEIA,
		"USAR_SHAKE": Constantes.USAR_SHAKE,
		"GRÁFICO_HIGH": Constantes.GRÁFICO_HIGH
	}
	return config

func setConfig(config_dict: Dictionary) -> void:
	if config_dict.is_empty():
		return
		
	Constantes.VOLUME_MASTER = config_dict.get("VOLUME_MASTER", Constantes.VOLUME_MASTER)
	Constantes.VOLUME_MUSICA = config_dict.get("VOLUME_MUSICA", Constantes.VOLUME_MUSICA)
	Constantes.VOLUME_SFX = config_dict.get("VOLUME_SFX", Constantes.VOLUME_SFX)
	Constantes.VOLUME_UI = config_dict.get("VOLUME_UI", Constantes.VOLUME_UI)
	Constantes.TELA_CHEIA = config_dict.get("TELA_CHEIA", Constantes.TELA_CHEIA)
	Constantes.USAR_SHAKE = config_dict.get("USAR_SHAKE", Constantes.USAR_SHAKE)
	Constantes.GRÁFICO_HIGH = config_dict.get("GRÁFICO_HIGH", Constantes.GRÁFICO_HIGH)
