# Scrolling camera for the auto-runner level. Kept as a sibling of the player
# (not a child) and only ever moved on the x axis, so jumping doesn't bob the
# camera the way a child camera would.
extends Camera2D

@export var target_path: NodePath = ^"../RunnerPlayer"
@export var lead_offset: float = 300.0
@export var fixed_y: float = 700.0

@onready var target: Node2D = get_node(target_path)


func _physics_process(_delta: float) -> void:
	if target:
		global_position = Vector2(target.global_position.x + lead_offset, fixed_y)
