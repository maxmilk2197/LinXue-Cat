extends NinePatchRect
signal state_changed(new_state)

enum State {
	开始游戏,
	设置,
	更多设置
}

var current_state = State.开始游戏

# 移动指针到指定全局位置，并可选改变状态
func move_to(target_global_pos: Vector2, new_state: State = current_state):
	if new_state != current_state:
		current_state = new_state
		state_changed.emit(new_state)
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_global_pos, 0.8)\
		 .set_trans(Tween.TRANS_QUINT)\
		 .set_ease(Tween.EASE_OUT)
