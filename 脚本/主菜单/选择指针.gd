extends NinePatchRect

signal state_changed(new_state)

enum State {
	开始游戏,
	设置,
	更多设置
}

var current_state = State.开始游戏

# 移动到目标全局中心点（例如按钮的中心）
func move_to(target_center: Vector2, new_state: State = current_state):
	if new_state != current_state:
		current_state = new_state
		state_changed.emit(new_state)
	
	# 计算指针左上角应处的位置
	var target_pos = target_center - size / 2
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, 0.8)\
		 .set_trans(Tween.TRANS_QUINT)\
		 .set_ease(Tween.EASE_OUT)
