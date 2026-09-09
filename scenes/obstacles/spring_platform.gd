# Bouncy square platform (drum/drums art) for the auto-runner level. Same
# icon-export pattern as platform.gd, but tagged "spring_platform" so
# runner_player.gd can detect landing on top and launch the player instead of
# just letting them stand on it.
extends StaticBody2D
class_name SpringPlatform

## Optional per-instance art override, set from the Inspector on each placed instance.
@export var icon: Texture2D
## Lets differently-sized source art read at a consistent size.
@export var icon_scale: Vector2 = Vector2.ONE

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	add_to_group("spring_platform")
	if icon:
		sprite.texture = icon
	sprite.scale = icon_scale
