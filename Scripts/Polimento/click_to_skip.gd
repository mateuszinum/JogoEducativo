extends CanvasItem

@export_group("Configurações de Saída")
@export var usar_fade: bool = false
@export var tempo_fade: float = 0.5

var _fechando: bool = false

func _ready() -> void:
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if not visible or _fechando:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_fechando = true
			
			if usar_fade:
				var tween = create_tween()
				tween.tween_property(self, "modulate:a", 0.0, tempo_fade)
				tween.tween_callback(fechar_tela)
			else:
				fechar_tela()

func fechar_tela() -> void:
	hide()
	modulate.a = 1.0
	_fechando = false
