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
var is_attacking = false
var keep_flip = false

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
	
	if Input.is_action_just_pressed("v_key"):
		is_attacking = true
		$PunchAudio.play()
		_animated_player.play("punch")
		$PunchHitbox.monitoring = true 
	
	if Input.is_action_just_released("v_key"):
		is_attacking = false
		$PunchHitbox.monitoring = false
	
	if is_on_floor():
		jump_count = 0

	if is_on_floor() and not Input.is_anything_pressed():
		_animated_player.play("idle")
	
	if Input.is_action_just_pressed('move_down'):
		if is_on_floor():
			_animated_player.play("duck")
		elif not is_on_floor():
			velocity.y = delta * gravity * 30
	
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
	if body.name == "Player":
		position.x = 200
		position.y = 50

func _on_punch_hitbox_body_entered(body) -> void:
	if body.is_in_group("enemy") and is_attacking:
		SignalBus.punch_hit.emit(body)
