# Auto-runner player for level_05 (Geometry Dash / Dino-style gameplay).
# Kept separate from scenes/player/player.gd so levels 1-4's free-movement
# player is never touched: here the player never reads left/right input —
# forward speed is forced and ramps up over time instead.
extends CharacterBody2D

const JUMP_VELOCITY := -813.0 # paired with RISE_GRAVITY_SCALE below to reach the same peak height as before, just quicker
const RISE_GRAVITY_SCALE := 2.0 # extra gravity while ascending only, so "up" resolves ~30% faster instead of feeling floaty
const RUN_SPEED_MIN := 300.0
const RUN_SPEED_MAX := 600.0
const RUN_ACCEL := 4.5 # px/s of forward speed gained per second
const COYOTE_TIME := 0.12 # seconds a jump still works after walking off a ledge
const JUMP_BUFFER_TIME := 0.12 # seconds a jump press is remembered before landing
const SPRING_VELOCITY := -900.0 # landing on a spring_platform auto-launches upward, no jump press needed
const SPRING_FORWARD_BOOST := 200.0 # extra forward speed added on that launch
const SPEED_BOOST_DECAY := 300.0 # px/s^2 the forward boost fades at

var _run_speed := RUN_SPEED_MIN
var _speed_boost := 0.0
var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0

@onready var sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	add_to_group("player")
	sprite.play("run")


func _physics_process(delta: float) -> void:
	# Fell into a pit — instant restart, same as hitting a hazard.
	if position.y > get_viewport_rect().size.y + 200:
		LevelManager.restart_level()
		return

	if not is_on_floor():
		var gravity_scale := RISE_GRAVITY_SCALE if velocity.y < 0.0 else 1.0
		velocity += get_gravity() * gravity_scale * delta

	_run_speed = min(_run_speed + RUN_ACCEL * delta, RUN_SPEED_MAX)
	_speed_boost = max(_speed_boost - SPEED_BOOST_DECAY * delta, 0.0)
	velocity.x = _run_speed + _speed_boost

	# Coyote time + jump buffering: a jump still fires if it's pressed a
	# little before landing, or a little after walking off a ledge, so a
	# near-miss press isn't punished as a failed jump.
	_coyote_timer = COYOTE_TIME if is_on_floor() else _coyote_timer - delta
	_jump_buffer_timer = JUMP_BUFFER_TIME if Input.is_action_just_pressed("jump") else _jump_buffer_timer - delta

	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		_coyote_timer = 0.0
		_jump_buffer_timer = 0.0

	move_and_slide()

	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		if col == null:
			continue
		var collider := col.get_collider()
		if collider == null:
			continue
		if collider.is_in_group("spring_platform") and col.get_normal().y < -0.5:
			velocity.y = SPRING_VELOCITY
			_speed_boost = SPRING_FORWARD_BOOST

	if is_on_floor():
		if sprite.animation != "run":
			sprite.play("run")
	elif sprite.animation != "jump":
		sprite.play("jump")
