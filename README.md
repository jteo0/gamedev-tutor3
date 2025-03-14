# Tutorial 3
- Double Jump: This is done by keeping count of how many jumps have been done mid air:<br>
<code>if is_on_floor():
		jump_count = 0</code>
- Dashing: This is done using a timer and boolean, multiplying the normal movement formula by 2.<br>
- Animations: This is done by making multiple animations in with AnimatedSprite, and then setting them to play when specific inputs are pressed. For example:<br>
<code>if Input.is_action_just_pressed('move_up'):
		_animated_player.play("jump")</code>
- Fast Falling: If the player is in the air and presses down, the player will fall faster. This is done by multiplying 5 to the usual gravity formula.<br>
<code>
if Input.is_action_just_pressed('move_down'):
		if is_on_floor():
			_animated_player.play("duck")
		elif not is_on_floor():
			velocity.y = delta * gravity * 5</code>
- Background: Tried to to a parallax background and it didn't work, but I used the ParallaxBackground and put in each layer into ParallaxLayers.<br>
- Flipping Directions: The player starts facing to the right, which is set as player_direction = true. The direction they're currently facing is reversed by multiplying the scale.x of the player by -1. It checks for direction using the player_direction bool.<br>
<code>var player_direction = true
if Input.is_action_pressed("move_left"):
		if player_direction:
			scale.x *= -1
			player_direction = false
elif Input.is_action_pressed("move_right"):
		if not player_direction:
			scale.x *= -1
			player_direction = true
</code>
- Respawning: When the player falls offscreen far enough, they will return to a specific spot on the scene. The position of the player is set with the following function when it enters the offscreen area.<br>
<code>
func _on_offscreen_limit_body_entered(body: CharacterBody2D) -> void:
	position.x = 200
	position.y = 50
</code>

# Tutorial 5
<h4>Extra Ground</h4>
I duplicated the ground that was already there from tutorial 3 and adjusted their position.x accordingly.
<h4>Zombie Enemies</h4>
The zombie enemies are spawned above the ground through Spawner.gd:

```py
extends Node2D

@export var obstacle : PackedScene
var camera

func _ready():
	repeat()

func spawn():
	var spawned = obstacle.instantiate()
	get_parent().add_child(spawned)

	var spawn_pos = global_position
	spawn_pos.x = spawn_pos.x + randf_range(0, 2000)

	spawned.global_position = spawn_pos

func repeat():
	spawn()
	await get_tree().create_timer(2).timeout
	repeat()

```
<br>
For movement, it's generally the same as the players'. The animations are the same, but instead of being controlled through key inputs, the zombies are consistently moving left or right. They have a 1% chance of switching directions every delta, and a 0.5% chance of jumping.<br>

```py
	move_and_slide()

	if is_on_floor and !is_dead:
		_animated_enemy.play("walk")
		
	if randf() < 0.01 and !is_dead:
		direction *= -1
		_animated_enemy.flip_h = !_animated_enemy.flip_h
	
	if randf() < 0.005 and is_on_floor() and !is_dead:
		_animated_enemy.play("jump")
		velocity.y = jump_speed
```

It's also slightly slower than the player, with a 75 walking_speed compared to the players' 200. In addition, if it gets hit by the player's punch, it plays the oof audio using an AudioStreamPlayer2D and the hurt animation of the AnimatedSprite2D. Then, after 0.7 seconds, the zombie that was punched will disappear.

```py
func _on_punch_received(attacked):
	if attacked == self:
		$HurtSound.play()
		_animated_enemy.stop()
		_animated_enemy.play("hurt")
		await get_tree().create_timer(0.7).timeout
		queue_free()
```
<h4>Player Punching</h4>
By pressing the V key, the player will be able to punch. This plays the punch animation of the player and the punching sound effect. The animation is done using an AnimatedSprite2D and the audio is played on AudioStreamPlayer2D with it's Volume dB attribute raised to 7.643 so it's louder. The code used to make it work is as follows:<br>

```py
	if Input.is_action_just_pressed("v_key"):
		is_attacking = true
		$PunchAudio.play()
		_animated_player.play("punch")
		$PunchHitbox.monitoring = true 
	
	if Input.is_action_just_released("v_key"):
		is_attacking = false
		$PunchHitbox.monitoring = false
```
<br>
Player.gd also emits a signal when the Area2D Punch Hitbox (the hitbox for the punch made using an Area2D node + a CollisionShape2D node) when it hits a body in the enemy group (the zombie enemies) and the player happens to be punching.<br>

```py
func _on_punch_hitbox_body_entered(body) -> void:
	if body.is_in_group("enemy") and is_attacking:
		SignalBus.punch_hit.emit(body)
```
<h4>Global/Autoload for Signals</h4>
In order for the ZombieEnemy scene to receive a signal from the Player scene, the signal was defined in SignalBus.gd, which is the global/autoload script.

```py
signal punch_hit
```
<br>
The signal is used in Player and ZombieEnemy as follows:<br>

```py
# Used in Player.gd
func _on_punch_hitbox_body_entered(body) -> void:
	if body.is_in_group("enemy") and is_attacking:
		SignalBus.punch_hit.emit(body)

# Used in ZombieEnemy.gd
func _ready():
	SignalBus.punch_hit.connect(_on_punch_received)
```
<h4>Instruction Label</h4>
The label tells the player that they can punch by pressing the V key. This is done by making the label a child node of player, though that comes at the consequence of it also flipping when the player does. The color was changed to black from the default white by changing the modulate attribute into black.<br>
<h4>Background</h4>
The cloud background was made using a canvas layer with multiple Sprite2D as child node for each layer (for aesthetics). The canvas layer makes the background automatically follow the camera as it moves around.<br>
References:<br>
- https://www.reddit.com/r/godot/comments/qry42j/comment/jirhcgp/?context=3<br>
- https://forum.godotengine.org/t/emitting-and-receiving-signals-in-between-scenes/66998/3<br>

Sounds from:
- https://quicksounds.com/sound/110/oof-roblox : roblox_oof.ogg<br>
- Swinging a drum stick : Swing.ogg<br>
- Whistling : loop_ogg.ogg
