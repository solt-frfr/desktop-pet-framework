extends Window

var click_pos = Vector2.ZERO
var ui_open = false
var moving = false

func _ready():
	get_viewport().transparent_bg = true
	$Menu.visible = false
	$CharacterSelect.visible = false

func _process(delta: float) -> void:
	if mode != MODE_WINDOWED:
		mode = Window.MODE_WINDOWED	
	if $Pet.is_user_movable && not ui_open:
		if Input.is_action_just_pressed("left_click"):
			var mouse_pos = DisplayServer.mouse_get_position()
			var window_size = DisplayServer.window_get_size()
			DisplayServer.window_set_position(mouse_pos - window_size / 2 + Vector2i(0, 30) )
			click_pos = mouse_pos - (mouse_pos - window_size / 2 + Vector2i(0, 30))
			$Pet/Sprite.play("drag")
			$Pet/Timer.stop()
			$Pet.is_sleeping = false
			moving = true
		if Input.is_action_just_pressed("right_click"):
			$Menu.visible = true
			ui_open = true
	elif moving && not ui_open:
		if Input.is_action_pressed("left_click"):
			DisplayServer.window_set_position(
				DisplayServer.mouse_get_position() - click_pos
			)
		if Input.is_action_just_released("left_click"):
			$Pet/Sprite.play("drop")
			$Pet/Timer.start(5)
			moving = false
	elif ui_open:
		if Input.is_action_just_pressed("right_click"):
			$Menu.visible = false
			ui_open = false
	


func _on_menu_item_activated(index: int) -> void:
	if index == 0:
		get_tree().quit()
	if index == 2:
		$CharacterSelect.visible = true


func _on_character_select_item_activated(index: int) -> void:
	pass # Replace with function body.
