extends Control

@onready var anim_intro = $AnimationPlayer

func _ready() -> void:
	anim_intro.play("SplashIntro")
	
func revelar_menu():
	$IntroLayer.hide()

func _process(delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/jogo.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
