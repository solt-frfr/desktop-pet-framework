extends Node2D

@export var is_actionable = false
@export var is_sleeping = false
@export var timer: Timer
@export var sprite: AnimatedSprite2D
@export var is_user_movable = false

func _ready():
	sprite.play("startup")
	timer.start(5)
	position = get_window().size / 2
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

	
func _process(delta):
	if is_actionable && not is_sleeping:
		is_actionable = false
		var randaction = randi_range(0, 34)
		if randaction < 25:
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


func _on_timer_timeout() -> void:
	is_actionable = true


func _on_sprite_animation_finished() -> void:
	if sprite.animation == "tosleep":
		sprite.play("sleep")
	else:
		sprite.play("idle0")


func _on_hitbox_mouse_entered() -> void:
	is_user_movable = true

func _on_hitbox_mouse_exited() -> void:
	is_user_movable = false
