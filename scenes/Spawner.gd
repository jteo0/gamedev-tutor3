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
