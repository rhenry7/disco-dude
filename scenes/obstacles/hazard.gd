# Instant-fail obstacle for the auto-runner level. Mirrors Collectible's
# icon-export pattern (scenes/collectibles/collectible.gd) and Goal's
# body_entered check, but restarts the level instead of collecting/completing it.
extends Area2D
class_name Hazard

## Optional per-instance art override, set from the Inspector on each placed instance.
@export var icon: Texture2D
## Lets differently-sized source art read at a consistent size.
@export var icon_scale: Vector2 = Vector2.ONE

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	add_to_group("hazard")
	if icon:
		sprite.texture = icon
	sprite.scale = icon_scale
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		LevelManager.restart_level()
