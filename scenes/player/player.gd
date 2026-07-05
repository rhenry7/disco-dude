# Reusable player character; lives in its own scene so any level can instance it.
# Membership in the "player" group is what lets Collectible detect pickups without
# a hard reference back to this script.
extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const SPRING_VELOCITY = -700.0

# A "ladder" is a container (e.g. Ladder/Ladder2 in level_02) of separate
# StaticBody2D steps in the "ladder_step" group, spaced closer together than
# the player is tall. Rather than disabling a step's shape — which would make
# it non-solid for every body, including enemies resting on it — the player
# adds a collision exception with every step except the one it's currently
# standing on. Exceptions are scoped to this body only, so other bodies still
# collide with every step normally.
var _ladder_container: Node = null
var _ladder_steps: Array[StaticBody2D] = []
var _current_step: StaticBody2D = null


func _ready() -> void:
	$Sprite.play("idle")


func _respawn() -> void:
	position = Vector2(55, 0)
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	var screen_bottom := get_viewport_rect().size.y - get_viewport_transform().get_origin().y
	if position.y > screen_bottom:
		_respawn()
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		$Sprite.play("jump")
		velocity.y = JUMP_VELOCITY
		_shift_ladder_step(-1)
		await $Sprite.animation_finished
		$Sprite.play("idle")

	# Drop down to the next step, one at a time (ladders).
	if Input.is_action_just_pressed("drop_down") and is_on_floor():
		_shift_ladder_step(1)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		$Sprite.flip_h = direction < 0
		if $Sprite.animation != "jump":
			$Sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if $Sprite.animation != "jump":
			$Sprite.play("idle")

	move_and_slide()

	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		if col == null:
			continue
		var collider := col.get_collider()
		if collider == null:
			continue
		if collider.is_in_group("notes") and col.get_normal().y < -0.5:
			velocity.y = SPRING_VELOCITY
			$Sprite.play("jump")
			var note: Node = collider.get_parent()
			if note is Collectible:
				note.collect()
			await $Sprite.animation_finished
			$Sprite.play("idle")
		elif collider is StaticBody2D and col.get_normal().y < -0.5:
			_on_landed(collider)


## Called whenever the player lands on top of a StaticBody2D. If it's a
## tagged ladder step, establishes (or updates) which single step of that
## ladder the player is allowed to collide with.
func _on_landed(step: StaticBody2D) -> void:
	if step == _current_step:
		return

	if not step.is_in_group("ladder_step"):
		_current_step = step
		return

	var container := step.get_parent()
	if container != _ladder_container:
		_reset_ladder()
		var siblings: Array[StaticBody2D] = []
		for child in container.get_children():
			if child is StaticBody2D and child.is_in_group("ladder_step"):
				siblings.append(child)
		siblings.sort_custom(func(a, b): return a.global_position.y < b.global_position.y)
		_ladder_container = container
		_ladder_steps = siblings

	_set_active_step(step)


## Clears every collision exception from the ladder the player just left, so a
## step isn't left permanently passable after the player moves on.
func _reset_ladder() -> void:
	for step in _ladder_steps:
		remove_collision_exception_with(step)
	_ladder_container = null
	_ladder_steps.clear()
	_current_step = null


func _set_active_step(step: StaticBody2D) -> void:
	for s in _ladder_steps:
		if s == step:
			remove_collision_exception_with(s)
		else:
			add_collision_exception_with(s)
	_current_step = step


## direction: 1 to drop down to the next step, -1 to jump up to the previous one.
func _shift_ladder_step(direction: int) -> void:
	if _current_step == null or _ladder_steps.is_empty():
		return
	var index := _ladder_steps.find(_current_step)
	var target_index := index + direction
	if target_index < 0:
		return
	if target_index >= _ladder_steps.size():
		# Off the bottom of the ladder — let the player drop freely instead of
		# indexing past the last step.
		add_collision_exception_with(_current_step)
		_current_step = null
		return
	_set_active_step(_ladder_steps[target_index])
