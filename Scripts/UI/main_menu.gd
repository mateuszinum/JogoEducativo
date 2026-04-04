extends Control

static var intro_ja_exibida: bool = false

@onready var anim_intro = $AnimationPlayer
@onready var intro_layer = $IntroLayer
@onready var transition_rect = $TransitionLayer/ColorRect

func _ready() -> void:
	if not Constantes.MODO_DEV and not intro_ja_exibida:
		anim_intro.play("SplashIntro")
		intro_ja_exibida = true
	else:
		pular_intro()
		
	if not Constantes.USAR_EFEITOS_TELA:
		if has_node("PosProcessamento"):
			$PosProcessamento.hide()

func revelar_menu():
	intro_layer.hide()

func pular_intro():
	intro_layer.hide()
	anim_intro.stop()

func _on_start_pressed() -> void:
	if $AudioStreamPlayer: $AudioStreamPlayer.stop()
	if has_node("SfxEntrar"): $SfxEntrar.play()
	
	var botao_start = $VBoxContainer/Button
	
	if botao_start.has_method("travar_no_clique"):
		botao_start.travar_no_clique()
	
	for botao in $VBoxContainer.get_children():
		if botao != botao_start:
			var tween_botao = create_tween()
			tween_botao.tween_property(botao, "modulate:a", 0.0, 1)
	
	transition_rect.show()
	transition_rect.modulate.a = 0.0
	
	var tween_tela = create_tween()
	tween_tela.tween_property(transition_rect, "modulate:a", 1.0, 2)
	
	await tween_tela.finished
	get_tree().change_scene_to_file("res://Scenes/UI/jogo.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
