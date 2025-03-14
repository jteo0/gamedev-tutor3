extends CharacterBody2D

@onready var _animated_enemy = $AnimatedEnemy

@export var gravity = 500.0
@export var walk_speed = 75
@export var jump_speed = -300

var is_dead = false
var direction = 1

func _ready():
	SignalBus.punch_hit.connect(_on_punch_received)
	
func _process(delta: float) -> void:
	if is_dead:
		_animated_enemy.stop()
		_animated_enemy.animation = "hurt"
		walk_speed = 0
		jump_speed = 0
	
func _physics_process(delta):
	velocity.y += delta * gravity
	velocity.x = walk_speed * direction	
	
	move_and_slide()

	if is_on_floor and !is_dead:
		_animated_enemy.play("walk")
		
	if randf() < 0.01 and !is_dead:
		direction *= -1
		_animated_enemy.flip_h = !_animated_enemy.flip_h
	
	if randf() < 0.005 and is_on_floor() and !is_dead:
		_animated_enemy.play("jump")
		velocity.y = jump_speed
				
func _on_punch_received(attacked):
	if attacked == self:
		$HurtSound.play()
		_animated_enemy.stop()
		_animated_enemy.play("hurt")
		await get_tree().create_timer(0.7).timeout
		queue_free()
