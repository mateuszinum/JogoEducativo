extends Node

func _ready() -> void:
	atualizar_buses()

func atualizar_buses() -> void:
	var master_bus = AudioServer.get_bus_index("Master")
	var musica_bus = AudioServer.get_bus_index("Musica")
	var sfx_bus = AudioServer.get_bus_index("SFX")
	var ui_bus = AudioServer.get_bus_index("UI")
	
	if master_bus != -1:
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(Constantes.VOLUME_MASTER * 2.0))
	if musica_bus != -1:
		AudioServer.set_bus_volume_db(musica_bus, linear_to_db(Constantes.VOLUME_MUSICA * 2.0))
	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(Constantes.VOLUME_SFX * 2.0))
	if ui_bus != -1:
		AudioServer.set_bus_volume_db(ui_bus, linear_to_db(Constantes.VOLUME_UI * 2.0))
