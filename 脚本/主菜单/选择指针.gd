extends NinePatchRect

@export var 移动时间 := 0.8
signal 状态改变(新状态)

enum 状态 {
	开始游戏,
	设置,
	更多设置
}

var 当前状态 = 状态.开始游戏

# 移动到目标全局中心点（例如按钮的中心）
func 移动到(目标中心: Vector2, 新状态: 状态 = 当前状态, 目标尺寸: Vector2 = size):
	if 新状态 != 当前状态:
		当前状态 = 新状态
		状态改变.emit(新状态)
	
	# 计算指针左上角应处的位置
	var 目标左上角 = 目标中心 - size / 2
	
	var 动画 = create_tween()
	动画.tween_property(self, "global_position", 目标左上角, 移动时间)\
		 .set_trans(Tween.TRANS_QUINT)\
		 .set_ease(Tween.EASE_OUT)
	
	# 如果传入了目标尺寸且与当前不同，同时改变大小
	if 目标尺寸 != size:
		动画.parallel().tween_property(self, "size", 目标尺寸, 移动时间)\
			 .set_trans(Tween.TRANS_QUINT)\
			 .set_ease(Tween.EASE_OUT)
