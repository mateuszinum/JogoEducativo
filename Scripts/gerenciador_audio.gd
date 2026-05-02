extends Node

var player_musica_atual: AudioStreamPlayer
var tween_musica: Tween

func _ready() -> void:
	Constantes.volume_alterado.connect(atualizar_buses)
	
	player_musica_atual = AudioStreamPlayer.new()
	player_musica_atual.bus = "Musica"
	add_child(player_musica_atual)
	
	atualizar_buses()

func tocar_musica(nova_musica: AudioStream, volume_alvo_db: float = 0.0, tempo_fade: float = 1.0, com_fade_in: bool = false) -> void:
	if not Constantes.TOCAR_MUSICA or nova_musica == null:
		return
		
	if player_musica_atual.stream == nova_musica and player_musica_atual.playing:
		return 

	if tween_musica and tween_musica.is_valid():
		tween_musica.kill()
		
	if player_musica_atual.playing:
		tween_musica = create_tween()
		tween_musica.tween_property(player_musica_atual, "volume_db", -80.0, tempo_fade)
		tween_musica.tween_callback(func(): _trocar_stream(nova_musica, volume_alvo_db, com_fade_in, tempo_fade))
	else:
		_trocar_stream(nova_musica, volume_alvo_db, com_fade_in, tempo_fade)

func _trocar_stream(nova_musica: AudioStream, volume_db: float, fade_in: bool, tempo: float) -> void:
	player_musica_atual.stream = nova_musica
	
	if fade_in:
		player_musica_atual.volume_db = -80.0
		player_musica_atual.play()
		var t = create_tween()
		t.tween_property(player_musica_atual, "volume_db", volume_db, tempo)
	else:
		player_musica_atual.volume_db = volume_db
		player_musica_atual.play()

func parar_musica(tempo_fade: float = 1.0) -> void:
	if not player_musica_atual.playing: return
	
	if tween_musica and tween_musica.is_valid():
		tween_musica.kill()
		
	tween_musica = create_tween()
	tween_musica.tween_property(player_musica_atual, "volume_db", -80.0, tempo_fade)
	tween_musica.tween_callback(func(): player_musica_atual.stop())

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
