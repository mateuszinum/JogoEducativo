extends Control

static var intro_ja_exibida: bool = false

@onready var anim_intro = $AnimationPlayer
@onready var intro_layer = $IntroLayer
@onready var transition_rect = $TransitionLayer/ColorRect

func _ready() -> void:
	if not intro_ja_exibida:
		anim_intro.play("SplashIntro")
		intro_ja_exibida = true
	else:
		pular_intro()

func revelar_menu():
	intro_layer.hide()

func pular_intro():
	intro_layer.hide()
	anim_intro.stop()

func _on_start_pressed() -> void:
	# 1. Para a música e toca o som de entrar
	if $AudioStreamPlayer: $AudioStreamPlayer.stop()
	if has_node("SfxEntrar"): $SfxEntrar.play()
	
	# Pegue a referência exata do seu botão "Jogar"
	var botao_start = $VBoxContainer/Button # Mude "Button" se o nome for outro
	
	# 2. Trava o visual do botão Jogar (mantém o hover/clique)
	if botao_start.has_method("travar_no_clique"):
		botao_start.travar_no_clique()
	
	# 3. O EFEITO DE FADE OUT DOS OUTROS BOTÕES
	for botao in $VBoxContainer.get_children():
		if botao != botao_start:
			# Cria um tween rápido para sumir com os outros botões
			var tween_botao = create_tween()
			tween_botao.tween_property(botao, "modulate:a", 0.0, 1)
	
	# 4. Inicia o Fade to Black da tela inteira
	transition_rect.show()
	transition_rect.modulate.a = 0.0
	
	var tween_tela = create_tween()
	# Dá um tempinho a mais (0.6s) para o jogador ver os outros botões sumindo
	tween_tela.tween_property(transition_rect, "modulate:a", 1.0, 2)
	
	# 5. Muda de cena só no final de tudo
	await tween_tela.finished
	get_tree().change_scene_to_file("res://Scenes/UI/jogo.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
