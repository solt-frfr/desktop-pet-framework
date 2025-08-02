extends Window

var click_pos = Vector2.ZERO
var ui_open = false
var moving = false
@export var timer: Timer
@export var alarm: Timer
@export var alarm_stop: Timer
@export var alarm_box: TextEdit
@export var taskbar_box: TextEdit
@export var alarm_button: Button
@export var menu: ItemList
@export var character_select: ItemList
@export var costume_select: ItemList
@export var hitbox: CollisionShape2D
@export var numpad: GridContainer
@export var border: TextureRect
var current_pet
var sit
var last_pet
var taskbar_height
var is_taskbar

var pet_name
var pet_idle_anims
var pet_sitidle_anims
var pet_clothes_toggles
var pet_clothes_names = []
var pet_toggle_style
var pet_sit_offset
var pet_drag_offset
var pet_scale
var alarm_length

func _ready():
	var save = ConfigFile.new()

	var err = save.load("user://save.ini")
	if err != OK:
		save.set_value("save_data", "last_pet", "Miles Edgeworth")
		save.set_value("save_data", "taskbar_height", 50)
		taskbar_height = 50
		last_pet = "Miles Edgeworth"
		save.save("user://save.ini")
	else:
		last_pet = save.get_value("save_data", "last_pet")
		taskbar_height = save.get_value("save_data", "taskbar_height")
	get_viewport().transparent_bg = true
	menu.visible = false
	character_select.visible = false
	costume_select.visible = false
	alarm_box.visible = false
	taskbar_box.visible = false
	numpad.visible = false
	alarm_button.visible = false
	border.visible = false
	# load_mods()
	var mods = get_mod_folders()
	var found_pet = false
	var current_pet_scene
	for mod in mods:
		var character = ConfigFile.new()

		var err2 = character.load("res://pet_scenes/" + mod + "/character.ini")
		if err2 != OK:
			return
		
		var name = character.get_value("character", "name")
		
		var image = ImageTexture.create_from_image(Image.load_from_file("res://pet_scenes/" + mod + "/icon.png"))
		image.set_size_override(Vector2(16, 16))
		
		character_select.add_item(name, image)
		if name == last_pet:
			current_pet_scene = load("res://pet_scenes/" + mod + "/character.tscn")
			found_pet = true
			pet_name = character.get_value("character", "name")
			pet_idle_anims = character.get_value("character", "idle_anims")
			pet_sitidle_anims = character.get_value("character", "sitidle_anims")
			pet_clothes_toggles = character.get_value("character", "clothes_toggles")
			pet_toggle_style = character.get_value("character", "toggle_style")
			pet_sit_offset = character.get_value("character", "sit_offset")
			pet_drag_offset = character.get_value("character", "drag_offset")
			pet_scale = character.get_value("character", "scale")
			alarm_length = character.get_value("character", "alarm_length")
			if pet_toggle_style != 0:
				var i = 0
				while i < pet_clothes_toggles:
					pet_clothes_names.append(character.get_value("character", "clothes_name" + str(i + 1)))
					costume_select.add_item(character.get_value("character", "clothes_name" + str(i + 1)))
					i += 1
			else:
				costume_select.add_item("No costumes.", null, false)
			break
			
	if not found_pet:
		current_pet_scene = load("res://pet_scenes/miles.solt11/character.tscn")
		pet_name = "Miles Edgeworth"
		pet_idle_anims = 2
		pet_sitidle_anims = 1
		pet_clothes_toggles = 0
		pet_toggle_style = 0
		pet_sit_offset = Vector2(0, 256)
		pet_drag_offset = Vector2(0, 30)
		pet_scale = 3
	current_pet = current_pet_scene.instantiate()
	add_child(current_pet)
	current_pet.apply_scale(Vector2(pet_scale, pet_scale))
	
func load_mods():
	var path = "user://mods/"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.contains(".pck"):
				ProjectSettings.load_resource_pack("user://mods/" + file_name)
				print("Loaded file: " + file_name,)
			else:
				print(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")
		
func get_mod_folders() -> Array:
	var mod_path = "res://pet_scenes"
	var mod_folders = []
	var dir = DirAccess.open(mod_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and not file_name.begins_with("."):
				mod_folders.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_error("Cannot open directory: " + mod_path)

	return mod_folders

	
func _input(event: InputEvent) -> void:
	if current_pet.is_user_movable && not ui_open:
		if event.is_action_pressed("left_click") && not moving:
			timer.start(0.25)
		if event.is_action_released("right_click"):
			menu.visible = true
			ui_open = true
			current_pet.ui_open = true
	elif ui_open:
		if event.is_action_released("right_click"):
			menu.visible = false
			character_select.visible = false
			costume_select.visible = false
			alarm_box.visible = false
			numpad.visible = false
			taskbar_box.visible = false
			current_pet.ui_open = false
			ui_open = false
	if event.is_action_released("left_click") && not ui_open && moving:
		if sit:
			current_pet.sprite.play("sitidle0")
			current_pet.is_sitting = true
		else:
			current_pet.sprite.play("drop")
			current_pet.is_sitting = false
		timer.stop()
		current_pet.timer.start(5)
		moving = false

func _process(delta: float) -> void:
	if mode != MODE_WINDOWED:
		mode = Window.MODE_WINDOWED
		
	if moving && not ui_open:
		DisplayServer.window_set_position(
				DisplayServer.mouse_get_position() - click_pos
		)
		if DisplayServer.screen_get_size().y - DisplayServer.mouse_get_position().y <= taskbar_height + 100:
			DisplayServer.window_set_position(
				Vector2(DisplayServer.mouse_get_position().x - click_pos.x, DisplayServer.screen_get_size().y - taskbar_height - pet_sit_offset)
			)
			sit = true
		else:
			sit = false
	if ui_open:
		set_passthrough_from_area(hitbox)
			
func set_passthrough_from_area(area: CollisionShape2D):
	var shape = area.shape
	var global_pos = area.global_position

	var points: PackedVector2Array

	if shape is RectangleShape2D:
		var extents = shape.extents
		points = PackedVector2Array([
			global_pos + Vector2(-extents.x, -extents.y),
			global_pos + Vector2(extents.x, -extents.y),
			global_pos + Vector2(extents.x, extents.y),
			global_pos + Vector2(-extents.x, extents.y)
		])
		DisplayServer.window_set_mouse_passthrough(points)

func _on_menu_item_activated(index: int) -> void:
	if index == 0:
		var save = ConfigFile.new()
		save.set_value("save_data", "last_pet", last_pet)
		save.set_value("save_data", "taskbar_height", taskbar_height)
		save.save("user://save.ini")
		get_tree().quit()
	if index == 1:
		character_select.visible = false
		costume_select.visible = true
		alarm_box.visible = false
		numpad.visible = false
		taskbar_box.visible = false
	if index == 2:
		character_select.visible = true
		costume_select.visible = false
		alarm_box.visible = false
		numpad.visible = false
		taskbar_box.visible = false
	if index == 3:
		if is_taskbar:
			numpad.set_position(Vector2(numpad.position.x, numpad.position.y - 80))
		is_taskbar = false
		character_select.visible = false
		costume_select.visible = false
		alarm_box.visible = true
		numpad.visible = true
		taskbar_box.visible = false
	if index == 4:
		border.visible = not border.visible
	if index == 5:
		current_pet.scale = Vector2(0 - current_pet.scale.x, current_pet.scale.y)
	if index == 6:
		if not is_taskbar:
			numpad.set_position(Vector2(numpad.position.x, numpad.position.y + 80))
		is_taskbar = true
		character_select.visible = false
		costume_select.visible = false
		alarm_box.visible = false
		numpad.visible = true
		taskbar_box.visible = true
		

func _on_character_select_item_activated(index: int) -> void:
	character_select.visible = false
	costume_select.visible = false
	alarm_box.visible = false
	numpad.visible = false
	menu.visible = false
	current_pet.ui_open = false
	ui_open = false
	remove_child(current_pet)
	var mods = get_mod_folders()
	var found_pet = false
	var current_pet_scene
	pet_clothes_names.clear()
	for mod in mods:
		var character = ConfigFile.new()

		var err2 = character.load("res://pet_scenes/" + mod + "/character.ini")
		if err2 != OK:
			return
		
		var name = character.get_value("character", "name")
		
		var image = ImageTexture.create_from_image(Image.load_from_file("res://pet_scenes/" + mod + "/icon.png"))
		image.set_size_override(Vector2(16, 16))
		
		character_select.add_item(name, image)
		if name == character_select.item_selected.get_name():
			current_pet_scene = load("res://pet_scenes/" + mod + "/character.tscn")
			found_pet = true
			pet_name = character.get_value("character", "name")
			last_pet = pet_name
			pet_idle_anims = character.get_value("character", "idle_anims")
			pet_sitidle_anims = character.get_value("character", "sitidle_anims")
			pet_clothes_toggles = character.get_value("character", "clothes_toggles")
			pet_toggle_style = character.get_value("character", "toggle_style")
			pet_sit_offset = character.get_value("character", "sit_offset")
			pet_drag_offset = character.get_value("character", "drag_offset")
			pet_scale = character.get_value("character", "scale")
			var i = 0
			while i < pet_clothes_toggles:
				pet_clothes_names.append(character.get_value("character", "clothes_name" + str(i + 1)))
				costume_select.add_item(character.get_value("character", "clothes_name" + str(i + 1)))
				i += 1
			break
			
	if not found_pet:
		current_pet_scene = load("res://pet_scenes/miles.solt11/character.tscn")
		pet_name = "Miles Edgeworth"
		last_pet = "Miles Edgeworth"
		pet_idle_anims = 2
		pet_sitidle_anims = 1
		pet_clothes_toggles = 0
		pet_toggle_style = 0
		pet_sit_offset = Vector2(0, 256)
		pet_drag_offset = Vector2(0, 30)
		pet_scale = 3
	current_pet = current_pet_scene.instantiate()
	add_child(current_pet)
	current_pet.apply_scale(Vector2(pet_scale, pet_scale))

func _on_costume_select_item_activated(index: int) -> void:
	character_select.visible = false
	costume_select.visible = false
	alarm_box.visible = false
	numpad.visible = false
	menu.visible = false
	current_pet.ui_open = false
	ui_open = false
	if pet_toggle_style == 1:
		current_pet.sprite.visible = false
		current_pet.sprite = current_pet.find_child("Sprite" + str(index + 1))
		current_pet.sprite.visible = true
		if current_pet.is_sleeping:
			current_pet.sprite.play("sleep")
		elif current_pet.is_sitting:
			current_pet.sprite.play("sitidle0")
		else:
			current_pet.sprite.play("idle0")
	elif pet_toggle_style == 2:
		current_pet.sprite.find_child("Costume" + str(index + 1)).visible = not current_pet.sprite.find_child("Costume" + str(index + 1)).visible

func _on_timer_timeout() -> void:
	if Input.is_action_pressed("left_click") && not moving:
		var mouse_pos = DisplayServer.mouse_get_position()
		var window_size = DisplayServer.window_get_size()
		if current_pet.scale.x > 0:
			DisplayServer.window_set_position(mouse_pos - window_size / 2 + pet_drag_offset)
			click_pos = mouse_pos - (mouse_pos - window_size / 2 + pet_drag_offset)
		else:
			DisplayServer.window_set_position(mouse_pos - window_size / 2 + Vector2i(0 - pet_drag_offset.x, pet_drag_offset.y))
			click_pos = mouse_pos - (mouse_pos - window_size / 2 + Vector2i(0 - pet_drag_offset.x, pet_drag_offset.y))
		current_pet.sprite.play("drag")
		current_pet.timer.stop()
		current_pet.is_sleeping = false
		moving = true

func _on_alarm_button_pressed() -> void:
	current_pet.timer.start(1)
	if sit:
		current_pet.sprite.play("sitidle0")
	else:
		current_pet.sprite.play("idle0")
	current_pet.alarm_on = false
	alarm_button.visible = false
	current_pet.alarm_player.stop()
	alarm_stop.stop()
	ui_open = false
	current_pet.ui_open = false


func _on_alarm_off() -> void:
	alarm_button.visible = true
	alarm_stop.start(alarm_length)
	ui_open = true
	current_pet.ui_open = true
	current_pet._on_alarm_timeout()


func _on_button_1_pressed() -> void:
	if is_taskbar:
		taskbar_box.text += str(1)
	else:
		alarm_box.text += str(1)


func _on_button_2_pressed() -> void:
	if is_taskbar:
		taskbar_box.text += str(2)
	else:
		alarm_box.text += str(2)

func _on_button_3_pressed() -> void:
	if is_taskbar:
		taskbar_box.text += str(3)
	else:
		alarm_box.text += str(3)


func _on_button_4_pressed() -> void:
	if is_taskbar:
		taskbar_box.text += str(4)
	else:
		alarm_box.text += str(4)


func _on_button_5_pressed() -> void:
	if is_taskbar:
		taskbar_box.text += str(5)
	else:
		alarm_box.text += str(5)


func _on_button_6_pressed() -> void:
	if is_taskbar:
		taskbar_box.text += str(6)
	else:
		alarm_box.text += str(6)


func _on_button_7_pressed() -> void:
	if is_taskbar:
		taskbar_box.text += str(7)
	else:
		alarm_box.text += str(7)


func _on_button_8_pressed() -> void:
	if is_taskbar:
		taskbar_box.text += str(8)
	else:
		alarm_box.text += str(8)


func _on_button_9_pressed() -> void:
	if is_taskbar:
		taskbar_box.text += str(9)
	else:
		alarm_box.text += str(9)


func _on_button_0_pressed() -> void:
	if is_taskbar:
		taskbar_box.text += str(0)
	else:
		alarm_box.text += str(0)


func _on_button_done_pressed() -> void:
	if is_taskbar:
		taskbar_box.text = str(float(taskbar_box.text))
		taskbar_height = float(taskbar_box.text)
		taskbar_box.text = ""
	else:
		alarm_box.text = str(float(alarm_box.text))
		alarm.start(float(alarm_box.text))
		alarm_box.text = ""
	alarm_box.visible = false
	taskbar_box.visible = false
	numpad.visible = false
	menu.visible = false
	ui_open = false
	current_pet.ui_open = false


func _on_alarm_stop_timeout() -> void:
	_on_alarm_button_pressed()
	ui_open = false
	current_pet.ui_open = false
