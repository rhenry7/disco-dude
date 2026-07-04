# Self-contained pickup. Registers itself in the "collectibles" group so any
# LevelBase can discover and track it without a hard-coded reference, and
# announces its own pickup via a signal instead of the level polling for it.
extends Area2D
class_name Collectible

signal collected(item)

## Optional per-instance art override, set from the Inspector on each placed instance.
@export var icon: Texture2D
## Lets differently-sized source art (e.g. a violin vs. a guitar image) read at a consistent size.
@export var icon_scale: Vector2 = Vector2.ONE

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	add_to_group("notes")
	if icon:
		sprite.texture = icon
	sprite.scale = icon_scale
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		collect()


## Shared by the Area2D overlap above and by anything (e.g. a physical bounce
## collision in player.gd) that needs to collect this item directly.
func collect() -> void:
	if is_queued_for_deletion():
		return
	collected.emit(self)
	queue_free()
