#extends Node2D
#
#const SCROLL_SPEED := 50.0
#const TILE_PADDING := 200.0
#
#var _grounds: Array = []
#var _tile_width: float = 0.0
#var _ground_y: float = 0.0  # top surface of the collision, used for respawn
#
#func _ready() -> void:
	#var original: StaticBody2D = $Ground
	#_compute_extents(original)
#
	#var copy: StaticBody2D = original.duplicate()
	#copy.position.x = original.position.x + _tile_width
	#add_child(copy)
#
	#_grounds = [original, copy]
#
#func _compute_extents(ground: StaticBody2D) -> void:
	#var min_x := INF
	#var max_x := -INF
	#var min_top := INF
#
	#for child in ground.get_children():
		#if not child is CollisionShape2D:
			#continue
		#var shape: Shape2D = child.shape
		#if not shape is RectangleShape2D:
			#continue
		#var hw: float = (shape as RectangleShape2D).size.x * 0.5
		#var hh: float = (shape as RectangleShape2D).size.y * 0.5
		#min_x = minf(min_x, child.position.x - hw)
		#max_x = maxf(max_x, child.position.x + hw)
		#min_top = minf(min_top, child.position.y - hh)
#
	#_tile_width = max_x - min_x
	#_ground_y = min_top
#
#func _process(delta: float) -> void:
	#for g in _grounds:
		#g.position.x -= SCROLL_SPEED * delta
#
	#var max_pos := -INF
	#for g in _grounds:
		#max_pos = maxf(max_pos, g.position.x)
#
	#var screen_left := to_local(Vector2.ZERO).x
	#for g in _grounds:
		#if g.position.x + (_tile_width * 0.5) < screen_left:
			#g.position.x = TILE_PADDING + max_pos + _tile_width + TILE_PADDING
#
	#var screen_bottom := to_local(Vector2(0.0, get_viewport_rect().size.y)).y
	#var player := $Player as CharacterBody2D
	#if player.position.y > screen_bottom:
		#player.position.y = _ground_y - 300.0
		#player.velocity = Vector2.ZERO
