extends Camera2D

signal state_changed(new_state)

enum State {
	主菜单,
	游戏存档,
	退出,
	设置,
	更多设置,
	更多设置_可滑动
}

var current_state = State.主菜单

# 滑动相关变量
var is_dragging = false
var drag_start_mouse_pos: Vector2
var drag_start_camera_pos: Vector2
var drag_sensitivity = 1.0


func change_state(new_state):
	current_state = new_state
	state_changed.emit(new_state)
	
	var tween = create_tween()
	var target_pos: Vector2   # 在 match 前声明变量
	
	match new_state:
		State.主菜单:
			target_pos = Vector2(240, 240)
		State.游戏存档:
			target_pos = Vector2(240,-240)
		State.设置:
			target_pos = Vector2(720, 240)
		State.退出:
			target_pos = Vector2(240, 720)
		State.更多设置:
			target_pos = Vector2(1200, 240)
	
	tween.tween_property(self, "position", target_pos, 0.8)\
		 .set_trans(Tween.TRANS_QUINT)\
		 .set_ease(Tween.EASE_OUT)


func _input(event: InputEvent):
	# 鼠标/触摸按下
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_start_mouse_pos = event.global_position
			drag_start_camera_pos = position
		else:
			is_dragging = false
	
	# 鼠标/触摸移动
	if event is InputEventMouseMotion and is_dragging:
		var mouse_delta = event.global_position - drag_start_mouse_pos
		var new_y = drag_start_camera_pos.y + mouse_delta.y * drag_sensitivity
		position.y = new_y
