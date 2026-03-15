extends Control

func _ready() -> void:
	$AnimationPlayer.play("RESET")

func _process(delta: float) -> void:
	testEsc()

func testEsc():
	if Input.is_action_just_pressed("pause_key") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("pause_key") and get_tree().paused == true:
		resume()

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")

func _on_continue_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()

func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
