extends Control

# Esta variável estática persiste na memória enquanto o executável estiver aberto.
# Ela não faz "reset" quando muda de cena.
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
	if $AudioStreamPlayer: $AudioStreamPlayer.stop()
	if has_node("SfxEntrar"): $SfxEntrar.play()
	
	var botao_start = $VBoxContainer/Button
	if botao_start.has_method("travar_no_clique"):
		botao_start.travar_no_clique()
	
	transition_rect.show()
	transition_rect.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(transition_rect, "modulate:a", 1.0, 0.6)
	
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/UI/jogo.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
