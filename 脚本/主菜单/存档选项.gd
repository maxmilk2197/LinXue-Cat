extends NinePatchRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"../ColorRect".hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_新游戏_pressed() -> void:
	var color_rect = $"../ColorRect"
	color_rect.modulate = Color(0,0,0,0)   # 纯黑透明
	color_rect.show()
	var tween = create_tween().bind_node(color_rect)
	tween.tween_property(color_rect, "modulate", Color.BLACK, 0.2)
	await tween.finished
	get_tree().change_scene_to_file("res://场景/对话界面.tscn")
