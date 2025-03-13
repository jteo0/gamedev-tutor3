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
