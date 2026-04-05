extends NinePatchRect

signal state_changed(new_state)

enum State {
	游戏存档,
	设置,
	退出,
}

# 动画总时长（秒），如果收缩时长超过总时长，则总时长自动调整为收缩时长
@export var animation_duration := 0.4
# 收缩为正方形的时长（秒），可单独调节
@export var shrink_duration := 0.3
# 禁止输入时长（秒），动画开始后一段时间内不接受新的旋转/悬停
@export var input_block_duration := 0.2

# 手动定义状态的顺序（与 UI 布局一致）
var state_order = [State.游戏存档, State.设置, State.退出]

var current_state = State.游戏存档
var previous_state = State.游戏存档
var input_blocked := false      # 是否处于禁止输入状态
var current_tween: Tween        # 保存当前动画的引用，以便打断

@onready var buttons = {
	State.游戏存档: $"../../主界面/开始",
	State.设置: $"../../主界面/设置",
	State.退出: $"../../主界面/退出",
}

@onready var indicator = self

func _ready():
	indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# 连接每个按钮的鼠标进入信号
	for state in buttons:
		var button = buttons[state]
		button.mouse_entered.connect(_on_button_mouse_entered.bind(state))
	
	# 初始定位（无动画）
	_place_indicator_at(current_state)

func _input(event: InputEvent):
	if input_blocked:
		return  # 禁止输入期间忽略旋转
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_rotate_state(-1)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_rotate_state(1)
			get_viewport().set_input_as_handled()

func _rotate_state(delta: int):
	var current_index = state_order.find(current_state)
	var new_index = (current_index + delta) % state_order.size()
	change_state(state_order[new_index])

func _on_button_mouse_entered(state: State):
	if input_blocked:
		return
	change_state(state)

func change_state(new_state: State):
	if new_state == current_state:
		return
	previous_state = current_state
	current_state = new_state
	state_changed.emit(new_state)
	move_indicator_to(previous_state, new_state)

# 直接放置指示器（无动画）
func _place_indicator_at(state: State):
	var button = buttons.get(state)
	if not button:
		return
	var size = indicator.size
	var pos = _get_centered_position(button, size)
	indicator.position = pos
	indicator.size = size

# 计算指示器应处的位置（使其中心与按钮中心对齐）
func _get_centered_position(button: Control, indicator_size: Vector2) -> Vector2:
	var button_center = button.get_global_rect().get_center()
	var parent = indicator.get_parent()
	var local_center = button_center - parent.global_position
	return local_center - indicator_size / 2

func move_indicator_to(from_state: State, to_state: State):
	var from_button = buttons.get(from_state)
	var to_button = buttons.get(to_state)
	if not from_button or not to_button:
		return
	
	# 如果已有动画，立即停止（这会自然保留动画到一半时的 size 和 position）
	if current_tween and current_tween.is_valid():
		current_tween.kill()
		current_tween = null
	
	# 目标大小（按钮大小）
	var target_size = to_button.get_global_rect().size
	
	# 【修复点1】：正方形的大小应该基于【目标按钮】的高或宽来定，而不是 current_size！
	# 这样即使动画被打断，它要变成的正方形大小始终是固定、正确的。
	var square_side = min(target_size.x, target_size.y)
	var square_size = Vector2(square_side, square_side)
	
	# 计算第一阶段（正方形）和第二阶段（最终大小）的目标居中位置
	var target_centered_square = _get_centered_position(to_button, square_size)
	var target_centered = _get_centered_position(to_button, target_size)
	
	# 确定收缩和扩展的时长
	var shrink = max(shrink_duration, 0.01)
	var expand = max(animation_duration - shrink, 0.01)
	if expand <= 0:
		expand = 0.01
		shrink = animation_duration
	
	# 开始禁止输入
	_block_input_for(input_block_duration)
	
	# 创建新动画
	current_tween = create_tween()
	current_tween.set_parallel(false)  # 顺序执行
	
	# 【修复点2】：调整了过渡动画曲线 (TRANS_CUBIC代替了TRANS_QUINT)
	# QUINT曲线极为剧烈，在0.1秒的短时间内像瞬间闪现。CUBIC更加柔和，能让人清晰地看到从正方形拉伸到长方形的过程。
	
	# 第一阶段：从当前被打断的状态 -> 移动并缩小为新目标的正方形
	current_tween.tween_property(indicator, "position", target_centered_square, shrink)\
		 .set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	current_tween.parallel().tween_property(indicator, "size", square_size, shrink)\
		 .set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	# 第二阶段：从正方形状态 -> 展开放大到目标大小
	if expand > 0:
		current_tween.tween_property(indicator, "position", target_centered, expand)\
			 .set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		current_tween.parallel().tween_property(indicator, "size", target_size, expand)\
			 .set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# 动画结束后清理引用
	current_tween.finished.connect(func(): 
		if current_tween == current_tween:  
			current_tween = null
	)

# 临时禁止输入，时长由参数决定
func _block_input_for(duration: float):
	if input_blocked:
		return
	input_blocked = true
	# 使用 SceneTreeTimer 延时解除阻塞
	get_tree().create_timer(duration).timeout.connect(func(): input_blocked = false)
