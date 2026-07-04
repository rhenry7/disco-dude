# Displays level progress. Kept dumb on purpose: it only knows how to render
# numbers it's handed, so LevelBase stays the single source of truth for state.
extends CanvasLayer
class_name HUD

@onready var label: Label = $Label


func update_progress(current: int, total: int) -> void:
	label.text = "%d / %d" % [current, total]
