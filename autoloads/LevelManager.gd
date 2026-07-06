# Autoload singleton: owns level ordering/progression so individual levels
# never need to know what comes next or how to get there.
extends Node

## Level scenes in play order. Add a path here to add a level — no script changes needed.
@export var levels: Array[String] = [
	"res://scenes/levels/level_01.tscn",
	"res://scenes/levels/level_02.tscn",
	"res://scenes/levels/level_03.tscn",
	"res://scenes/levels/level_04.tscn",
]

var current_index: int = 0


func level_completed() -> void:
	get_tree().paused = false
	current_index += 1
	if current_index < levels.size():
		get_tree().change_scene_to_file(levels[current_index])
	else:
		get_tree().change_scene_to_file("res://scenes/levels/game_complete.tscn")


func restart_level() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
