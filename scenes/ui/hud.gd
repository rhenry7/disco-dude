# Displays which level is active. Kept dumb on purpose: it only knows how to
# render the number it's handed, so LevelBase stays the single source of truth for state.
extends CanvasLayer
class_name HUD

@onready var label: Label = $Label
@onready var restart_button: TextureButton = $Controls/RestartButton
@onready var play_pause_button: TextureButton = $Controls/PlayPauseButton
@onready var next_button: TextureButton = $Controls/NextButton


func _ready() -> void:
	restart_button.pressed.connect(LevelManager.restart_level)
	next_button.pressed.connect(LevelManager.level_completed)
	play_pause_button.toggled.connect(_on_play_pause_toggled)


func set_level(level_number: int) -> void:
	label.text = "Level %d" % level_number


func _on_play_pause_toggled(paused: bool) -> void:
	get_tree().paused = paused
