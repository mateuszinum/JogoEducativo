extends Node2D

@onready var label = $Label

func setup(damage_amount: float):
	var amount = snapped(damage_amount, 0.1)
	var text_value = str(amount)
	
	if text_value.ends_with(".0"):
		text_value = text_value.left(-2)
	
	label.text = text_value
	label.pivot_offset = label.size / 2 
	
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(self, "position:y", position.y - 30, 0.4).set_ease(Tween.EASE_OUT)
	
	label.scale = Vector2(0.3, 0.3)
	tween.tween_property(label, "scale", Vector2(1.5, 1.5), 0.1)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.1)
	
	tween.tween_property(self, "modulate:a", 0.0, 0.3).set_delay(0.2)
	
	tween.chain().tween_callback(queue_free)
