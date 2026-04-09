extends CanvasLayer

@onready var label = Label.new()

func _ready():
	add_child(label)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE # O tracker não pode se detectar
	# Estilo para leitura fácil
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0.8)
	label.add_theme_stylebox_override("normal", sb)

func _process(_delta):
	var m_pos = get_viewport().get_mouse_position()
	var hovered = _find_hovered_control(get_tree().root, m_pos)
	
	if hovered:
		label.text = " Nome: " + hovered.name + "\n Classe: " + hovered.get_class() + "\n MouseFilter: " + _get_filter_name(hovered.mouse_filter) + " "
		label.visible = true
	else:
		label.text = "Nenhum Control sob o mouse"
	
	label.global_position = m_pos + Vector2(20, 20)

func _find_hovered_control(node: Node, pos: Vector2) -> Control:
	# Busca recursiva do nó mais profundo (que está na frente)
	if node is Control and node.visible and node.get_global_rect().has_point(pos):
		if node.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			for i in range(node.get_child_count() - 1, -1, -1):
				var found = _find_hovered_control(node.get_child(i), pos)
				if found: return found
			return node
	
	# Se não for control, ainda checa filhos (ex: CanvasLayer ou Window)
	for i in range(node.get_child_count() - 1, -1, -1):
		var found = _find_hovered_control(node.get_child(i), pos)
		if found: return found
	return null

func _get_filter_name(f):
	return ["STOP", "PASS", "IGNORE"][f]
