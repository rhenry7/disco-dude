# Reusable player character; lives in its own scene so any level can instance it.
# Membership in the "player" group is what lets Collectible detect pickups without
# a hard reference back to this script.
extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const SPRING_VELOCITY = -700.0

# A "ladder" body (e.g. Ground1 in level_02) is a single StaticBody2D with many
# stacked CollisionShape2D steps whose gaps are narrower than the player is
# tall. That means the player's body always overlaps more than one step at
# once, so only ever letting exactly one step on that body be solid — and
# shifting which one on jump/drop — avoids being wedged between two at a time.
var _ladder_body: Node = null
var _ladder_steps: Array[CollisionShape2D] = []
var _current_step: CollisionShape2D = null


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
		elif collider is CollisionObject2D and col.get_normal().y < -0.5:
			var shape_owner: int = collider.shape_find_owner(col.get_collider_shape_index())
			var step := collider.shape_owner_get_owner(shape_owner) as CollisionShape2D
			if step != null:
				_on_landed(step)


## Called whenever the player lands on top of a CollisionShape2D. Establishes
## (or updates) which single step on that body is allowed to be solid.
func _on_landed(step: CollisionShape2D) -> void:
	if step == _current_step:
		return

	var body := step.get_parent()
	if body != _ladder_body:
		_reset_ladder()
		var siblings: Array[CollisionShape2D] = []
		for child in body.get_children():
			if child is CollisionShape2D:
				siblings.append(child)
		if siblings.size() > 1:
			siblings.sort_custom(func(a, b): return a.global_position.y < b.global_position.y)
			_ladder_body = body
			_ladder_steps = siblings

	if step in _ladder_steps:
		_set_active_step(step)
	else:
		_current_step = step


## Re-enables every step of the ladder the player just left and clears tracking,
## so a body isn't left with steps permanently disabled after the player moves on.
func _reset_ladder() -> void:
	for step in _ladder_steps:
		step.disabled = false
	_ladder_body = null
	_ladder_steps.clear()
	_current_step = null


func _set_active_step(step: CollisionShape2D) -> void:
	for s in _ladder_steps:
		s.disabled = s != step
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
		_current_step.disabled = true
		_current_step = null
		return
	_set_active_step(_ladder_steps[target_index])
