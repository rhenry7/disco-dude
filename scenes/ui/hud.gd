# Displays which level is active. Kept dumb on purpose: it only knows how to
# render the number it's handed, so LevelBase stays the single source of truth for state.
extends CanvasLayer
class_name HUD

@onready var label: Label = $Label


func set_level(level_number: int) -> void:
	label.text = "Level %d" % level_number
