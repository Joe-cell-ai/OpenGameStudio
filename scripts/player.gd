extends CharacterBody3D
class_name AdventurePlayer

@export var move_speed: float = 6.0
@export var jump_velocity: float = 5.5
@export var mouse_sensitivity: float = 0.003
@export var gravity: float = 18.0

@onready var spring_arm: SpringArm3D = $SpringArm3D

var mobile_move := Vector2.ZERO
var mobile_look := Vector2.ZERO
var jump_requested := false
var _jump_was_down := false

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        spring_arm.rotate_x(-event.relative.y * mouse_sensitivity)
        spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-65), deg_to_rad(35))
    elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta

    var keyboard := Vector2(
        float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A)),
        float(Input.is_key_pressed(KEY_S)) - float(Input.is_key_pressed(KEY_W))
    )
    var input_vector := keyboard
    if mobile_move.length() > 0.12:
        input_vector = mobile_move
    input_vector = input_vector.limit_length()

    var direction := (transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
    if direction:
        velocity.x = direction.x * move_speed
        velocity.z = direction.z * move_speed
    else:
        velocity.x = move_toward(velocity.x, 0, move_speed * 6.0 * delta)
        velocity.z = move_toward(velocity.z, 0, move_speed * 6.0 * delta)

    var jump_down := Input.is_key_pressed(KEY_SPACE) or jump_requested
    if jump_down and not _jump_was_down and is_on_floor():
        velocity.y = jump_velocity
    _jump_was_down = jump_down
    jump_requested = false

    if mobile_look.length() > 0:
        rotate_y(-mobile_look.x * mouse_sensitivity * 2.0)
        spring_arm.rotate_x(-mobile_look.y * mouse_sensitivity * 2.0)
        spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-65), deg_to_rad(35))
        mobile_look = Vector2.ZERO

    move_and_slide()
