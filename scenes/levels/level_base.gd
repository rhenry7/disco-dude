# Shared level scaffolding. Every level scene inherits this one, so adding a
# new level is just "new inherited scene + place Collectibles + set
# required_items" — no new logic needed.
extends Node2D
class_name LevelBase

## Editable per-level from the Inspector on each inherited scene.
@export var required_items: int = 1

@onready var hud: HUD = $HUD

var collected_items: int = 0


func _ready() -> void:
	for collectible in get_tree().get_nodes_in_group("collectibles"):
		collectible.collected.connect(_on_item_collected)
	hud.update_progress(collected_items, required_items)


func _on_item_collected(_item: Collectible) -> void:
	collected_items += 1
	hud.update_progress(collected_items, required_items)
	if collected_items >= required_items:
		LevelManager.level_completed()
