extends Node2D

@onready var start_button: Button = $Control/StartButton

func _ready() -> void:
	start_button.pressed.connect(LevelManager.level_completed)
