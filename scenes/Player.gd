extends CharacterBody2D

@onready var _animated_player = %AnimatedPlayer

@export var gravity = 500.0
@export var walk_speed = 200
@export var jump_speed = -300

var right_dash_timer = 0
var left_dash_timer = 0
var player_direction = true
var is_dashing_right = false
var is_dashing_left = false

var jump_count = 0

func _process(delta: float):
	if right_dash_timer > 0:
		right_dash_timer -= delta
	if left_dash_timer > 0:
		left_dash_timer -= delta
		
	if Input.is_action_just_released('move_left'):
		is_dashing_left = false
		left_dash_timer = 0.25
	if Input.is_action_just_released('move_right'):
		is_dashing_right = false
		right_dash_timer = 0.25

func _physics_process(delta):
	velocity.y += delta * gravity

	if is_on_floor():
		jump_count = 0

	if is_on_floor() and not Input.is_anything_pressed():
		_animated_player.play("idle")
	
	if Input.is_action_just_pressed('move_down'):
		if is_on_floor():
			_animated_player.play("duck")
		elif not is_on_floor():
			velocity.y = delta * gravity * 5
	
	if Input.is_action_just_pressed('move_up'):
		_animated_player.play("jump")
		if jump_count < 2:
			velocity.y = jump_speed
			jump_count += 1

	if Input.is_action_pressed("move_left"):
		if player_direction:
			scale.x *= -1
			player_direction = false
		if is_on_floor():
			_animated_player.play("walk")
		else:
			_animated_player.play("jump")
		if left_dash_timer > 0 or is_dashing_left == true:
			is_dashing_left = true
			velocity.x = -walk_speed * 2
		else:
			velocity.x = -walk_speed
	elif Input.is_action_pressed("move_right"):
		if not player_direction:
			scale.x *= -1
			player_direction = true
		if is_on_floor():
			_animated_player.play("walk")
		else:
			_animated_player.play("jump")
		if right_dash_timer > 0 or is_dashing_right == true:
			is_dashing_right = true
			velocity.x = walk_speed * 2
		else:
			velocity.x =  walk_speed
	else:
		velocity.x = 0
		
	if is_on_floor() and Input.is_action_just_pressed('spacebar'):
		_animated_player.play("cheer")

	move_and_slide()

func _on_offscreen_limit_body_entered(body: CharacterBody2D) -> void:
	position.x = 200
	position.y = 50
