extends Camera2D
signal state_changed(new_state)

enum State {
	主菜单,
	游戏存档,
	退出,
	设置,
	更多设置
}

var current_state = State.主菜单

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
