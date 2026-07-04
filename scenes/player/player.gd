# Reusable player character; lives in its own scene so any level can instance it.
# Membership in the "player" group is what lets Collectible detect pickups without
# a hard reference back to this script.
extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const SPRING_VELOCITY = -700.0

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
		await $Sprite.animation_finished
		$Sprite.play("idle")

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
