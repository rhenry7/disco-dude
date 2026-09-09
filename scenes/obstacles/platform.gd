# Reusable ground/floating platform for the auto-runner level. Mirrors
# Collectible's icon-export pattern (scenes/collectibles/collectible.gd) so
# level_05 can reuse one scene with any of the platforms/3x textures.
extends StaticBody2D
class_name Platform

## Optional per-instance art override, set from the Inspector on each placed instance.
@export var icon: Texture2D
## Lets differently-sized source art read at a consistent size.
@export var icon_scale: Vector2 = Vector2.ONE

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if icon:
		sprite.texture = icon
	sprite.scale = icon_scale
