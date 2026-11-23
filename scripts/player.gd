extends CharacterBody3D

const SPEED = 6.0
const JUMP_VELOCITY = 7.5
const GRAVITY_MULTIPLIER = 2.2
const ROTATION_SPEED = 10.0
const MOUSE_SENSITIVITY = 0.003

@onready var anim_player: AnimationPlayer = $Ninja_Male/AnimationPlayer
@onready var model: Node3D = $Ninja_Male
@onready var camera_pivot: SpringArm3D = $CameraPivot

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotate(Vector3.UP, -event.relative.x * MOUSE_SENSITIVITY)
		camera_pivot.rotate_object_local(Vector3.RIGHT, -event.relative.y * MOUSE_SENSITIVITY)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-65), deg_to_rad(35))
		camera_pivot.rotation.z = 0.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * GRAVITY_MULTIPLIER * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var cam_basis := Basis(Vector3.UP, camera_pivot.rotation.y)
	var direction := (cam_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		var target_angle := atan2(direction.x, direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_angle, ROTATION_SPEED * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	_update_animation()

func _update_animation() -> void:
	if not is_on_floor():
		anim_player.play("Jump")
	elif velocity.length() > 0.1:
		anim_player.play("Run")
	else:
		anim_player.play("Idle")
