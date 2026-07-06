# Attached to each lyric StaticBody2D in level_04. Gravity starts off, so the
# word sits inert; touching it switches gravity on and it drops off the
# bottom of the screen — but only for the specific word that was touched.
# Collision is left untouched throughout, so this only ever affects the word
# itself, never the player's own collision with it.
extends StaticBody2D

const ACTIVE_GRAVITY := 700.0

var _gravity := 0.0
var _velocity := Vector2.ZERO


func fall() -> void:
	_gravity = ACTIVE_GRAVITY


func _physics_process(delta: float) -> void:
	if _gravity == 0.0:
		return
	_velocity.y += _gravity * delta
	position += _velocity * delta

	var screen_bottom := get_viewport_rect().size.y - get_viewport_transform().get_origin().y
	if global_position.y > screen_bottom:
		queue_free()
