extends Node2D

@export var is_actionable = false
@export var is_sleeping = false
@export var is_sitting = false
@export var is_user_movable = false
@export var alarm_on = false
@export var timer: Timer
@export var sprite: AnimatedSprite2D
@export var alarm_player: AudioStreamPlayer
@export var particles: GPUParticles2D
@export var hitbox: Area2D

var ui_open = false
var pet_scale
var alarm_length

func _ready():
	sprite.play("startup")
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	var save = ConfigFile.new()
	save.load(scene_file_path.replace(".tscn", ".ini"))
	pet_scale = save.get_value("character", "scale")
	alarm_length = save.get_value("character", "alarm_length")

func _process(delta):
	if not ui_open:
		set_passthrough_from_area(hitbox.active_shape)
	position = get_window().size / 2
	if is_actionable && not is_sleeping && not is_sitting:
		is_actionable = false
		var randaction = randi_range(1, 100)
		if randaction < 90:
			# Play and idle animation
			var randtime = randi_range(5, 15)
			var randanim = randi_range(1, 2)
			var anim = "idle" + str(randanim)
			sprite.play(anim)
			timer.start(randtime)
		else:
			# Sleep
			sprite.play("tosleep")
			is_sleeping = true
	elif is_actionable && not is_sleeping && is_sitting:
		is_actionable = false
		var randtime = randi_range(5, 15)
		var randanim = randi_range(1, 1)
		var anim = "sitidle" + str(randanim)
		sprite.play(anim)
		timer.start(randtime)
		
		
func set_passthrough_from_area(area: CollisionShape2D):
	var shape = area.shape
	var global_pos = area.global_position

	var points: PackedVector2Array

	if shape is RectangleShape2D:
		var extents = shape.extents
		points = PackedVector2Array([
			global_pos + Vector2(-extents.x, -extents.y) * pet_scale,
			global_pos + Vector2(extents.x, -extents.y) * pet_scale,
			global_pos + Vector2(extents.x, extents.y) * pet_scale,
			global_pos + Vector2(-extents.x, extents.y) * pet_scale
		])

	elif shape is CircleShape2D:
		var radius = shape.radius
		var segments = 16
		for i in range(segments):
			var angle = i * TAU / segments
			points.append(global_pos + Vector2(cos(angle), sin(angle)) * radius * pet_scale)

	elif shape is ConvexPolygonShape2D:
		for point in shape.points:
			points.append(area.to_global(point) * pet_scale)
	else:
		push_warning("Unsupported shape type for mouse passthrough")

	if points.size() > 2:
		DisplayServer.window_set_mouse_passthrough(points)


func _on_timer_timeout() -> void:
	is_actionable = true
	if alarm_on:
		alarm_player.stop()
		alarm_on = false


func _on_sprite_animation_finished() -> void:
	if sprite.animation == "startup":
		timer.start(5)
	if sprite.animation == "tosleep":
		sprite.play("sleep")
	elif sprite.animation.contains("sitidle"):
		sprite.play("sitidle0")
	else:
		sprite.play("idle0")
	if sprite.animation.contains("react"):
		is_actionable = true

func _on_hitbox_mouse_entered() -> void:
	is_user_movable = true

func _on_hitbox_mouse_exited() -> void:
	is_user_movable = false

func _on_alarm_timeout() -> void:
	alarm_on = true
	sprite.play("alarm")
	timer.start(alarm_length)
	alarm_player.play()
	is_sleeping = false

func _on_alarm_player_finished() -> void:
	if alarm_on:
		alarm_player.play()

func _on_chest_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_click") && not alarm_on && not is_sitting:
		var randtime = randi_range(5, 15)
		timer.start(randtime)
		sprite.play("react_chest")
		is_sleeping = false
		particles.position = $Head.active_shape.position - Vector2(6, 6)
		particles.texture = load(scene_file_path.replace("character.tscn", "sprites/chest.png"))
		particles.emit_particle(Transform2D(), Vector2(), Color8(0,0,0), Color8(0,0,0), 0)
		particles.emit_particle(Transform2D(), Vector2(), Color8(0,0,0), Color8(0,0,0), 0)
		particles.emit_particle(Transform2D(), Vector2(), Color8(0,0,0), Color8(0,0,0), 0)
	elif event.is_action_pressed("left_click") && not alarm_on && is_sitting:
		particles.position = $Head.active_shape.position - Vector2(6, 6)
		particles.texture = load(scene_file_path.replace("character.tscn", "sprites/chest.png"))
		particles.emit_particle(Transform2D(), Vector2(), Color8(0,0,0), Color8(0,0,0), 0)
		particles.emit_particle(Transform2D(), Vector2(), Color8(0,0,0), Color8(0,0,0), 0)
		particles.emit_particle(Transform2D(), Vector2(), Color8(0,0,0), Color8(0,0,0), 0)

func _on_crotch_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_click") && not alarm_on && not is_sitting:
		var randtime = randi_range(5, 15)
		timer.start(randtime)
		sprite.play("react_crotch")
		is_sleeping = false
		particles.position = $Head.active_shape.position - Vector2(6, 6)
		particles.texture = load(scene_file_path.replace("character.tscn", "sprites/crotch.png"))
		particles.emit_particle(Transform2D(), Vector2(), Color8(0,0,0), Color8(0,0,0), 0)
		particles.emit_particle(Transform2D(), Vector2(), Color8(0,0,0), Color8(0,0,0), 0)
		particles.emit_particle(Transform2D(), Vector2(), Color8(0,0,0), Color8(0,0,0), 0)
	elif event.is_action_pressed("left_click") && not alarm_on && is_sitting:
		particles.position = $Head.active_shape.position - Vector2(6, 6)
		particles.texture = load(scene_file_path.replace("character.tscn", "sprites/crotch.png"))
		particles.emit_particle(Transform2D(), Vector2(), Color8(0,0,0), Color8(0,0,0), 0)
		particles.emit_particle(Transform2D(), Vector2(), Color8(0,0,0), Color8(0,0,0), 0)
		particles.emit_particle(Transform2D(), Vector2(), Color8(0,0,0), Color8(0,0,0), 0)


func _on_head_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_click") && not alarm_on && not is_sitting:
		var randtime = randi_range(5, 15)
		timer.start(randtime)
		sprite.play("react_head")
		is_sleeping = false
		particles.position = $Head.active_shape.position - Vector2(6, 6)
		particles.texture = load(scene_file_path.replace("character.tscn", "sprites/head.png"))
		particles.emit_particle(Transform2D(), Vector2(), Color8(0,0,0), Color8(0,0,0), 0)
		particles.emit_particle(Transform2D(), Vector2(), Color8(0,0,0), Color8(0,0,0), 0)
		particles.emit_particle(Transform2D(), Vector2(), Color8(0,0,0), Color8(0,0,0), 0)
	elif event.is_action_pressed("left_click") && not alarm_on && is_sitting:
		particles.position = $Head.active_shape.position - Vector2(6, 6)
		particles.texture = load(scene_file_path.replace("character.tscn", "sprites/head.png"))
		particles.emit_particle(Transform2D(), Vector2(), Color8(0,0,0), Color8(0,0,0), 0)
		particles.emit_particle(Transform2D(), Vector2(), Color8(0,0,0), Color8(0,0,0), 0)
		particles.emit_particle(Transform2D(), Vector2(), Color8(0,0,0), Color8(0,0,0), 0)
