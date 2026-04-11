extends Button 

@export_group("Animação")
@export var escala_hover: Vector2 = Vector2(1.1, 1.1) 
@export var escala_clique: Vector2 = Vector2(0.9, 0.9) 
@export var tempo_transicao: float = 0.1 

@export_group("Sons")
@export var som_hover: AudioStream
@export_range(-40.0, 10.0) var volume_hover_db: float = 0.0
@export var som_clique: AudioStream
@export_range(-40.0, 10.0) var volume_clique_db: float = 0.0
@export var pitch_min: float = 0.9
@export var pitch_max: float = 1.1

var travado: bool = false 
var sfx_player: AudioStreamPlayer

func _ready() -> void: 
	mouse_entered.connect(_on_mouse_entered) 
	mouse_exited.connect(_on_mouse_exited) 
	button_down.connect(_on_button_down) 
	button_up.connect(_on_button_up) 
	pivot_offset = size / 2 
	
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "UI"
	add_child(sfx_player)

func travar_no_clique() -> void:
	travado = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE 
	_animar_escala(escala_clique) 

func _on_mouse_entered() -> void: 
	if travado: return
	pivot_offset = size / 2 
	_animar_escala(escala_hover) 
	_tocar_som(som_hover, volume_hover_db)

func _on_mouse_exited() -> void: 
	if travado: return
	_animar_escala(Vector2.ONE) 

func _on_button_down() -> void: 
	if travado: return
	_animar_escala(escala_clique)
	_tocar_som(som_clique, volume_clique_db)

func _on_button_up() -> void: 
	if travado: return
	var target = escala_hover if is_hovered() else Vector2.ONE
	_animar_escala(target)

func _animar_escala(target_scale: Vector2) -> void: 
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT) 
	tween.tween_property(self, "scale", target_scale, tempo_transicao)

func _tocar_som(stream: AudioStream, volume: float) -> void:
	if stream:
		sfx_player.stream = stream
		sfx_player.volume_db = volume
		sfx_player.pitch_scale = randf_range(pitch_min, pitch_max)
		sfx_player.play()
