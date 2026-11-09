extends PanelContainer

@onready var icone_rect = $VBoxContainer/Icone
@onready var tempo_label = $VBoxContainer/Tempo
@onready var progress_bar = $VBoxContainer/Barra

var tempo_restante: float = 0.0

func iniciar(icone_textura: Texture2D, duracao: float, cor_da_barra: Color):
	icone_rect.texture = icone_textura
	tempo_restante = duracao
	
	progress_bar.max_value = duracao
	progress_bar.value = duracao
	
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = cor_da_barra
	progress_bar.add_theme_stylebox_override("fill", style_box)

func adicionar_tempo(tempo_extra: float):
	tempo_restante += tempo_extra
	progress_bar.max_value = tempo_restante
	progress_bar.value = tempo_restante

func _process(delta: float):
	if tempo_restante > 0:
		tempo_restante -= delta
		progress_bar.value = tempo_restante
		tempo_label.text = str(int(ceil(tempo_restante))) + "s"
	else:
		queue_free()
