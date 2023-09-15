extends CharacterBody3D


const SPEED = 5.0
const ACCELERATION = 20
const AIR_CONTROL = 0.05
const JUMP_VELOCITY = 4.5

var direction = Vector3()
var speedlastframe

var viewrotation_x = 0.0
var viewrotation_y = 0.0

@onready var camera := $CollisionShape3d/Camera3d
@onready var capsule := $CollisionShape3d

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_object_local(up_direction, -event.relative.x * 0.001)
			
			#set view rotation vars for use in the camera position function
			viewrotation_x = clamp((camera.rotation.x + -event.relative.y * 0.001), deg_to_rad(-89), deg_to_rad(89)) 
			viewrotation_y = global_rotation.y
			
			#old code. only works if Camera is not top-level
			#camera.rotate_x(-event.relative.y * 0.001)
			#camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

# get speed
func getspeed():
	return SPEED

# get acceleration, modulated by air control, etc
func getacceleration():
	if is_on_floor():
		return ACCELERATION
	else:
		return ACCELERATION * AIR_CONTROL

# main movement update
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_l", "move_r", "move_f", "move_b")
	
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), getacceleration() * delta)
	
	if direction:
		velocity.x = direction.x * getspeed()
		velocity.z = direction.z * getspeed()
	else:
		velocity.x = move_toward(velocity.x, 0, getspeed())
		velocity.z = move_toward(velocity.z, 0, getspeed())
	move_and_slide()

# Physics framerate fix, to make camera movement feel smooth. chop up position by current framerate and lerp
func _process(delta):
	var fps = Engine.get_frames_per_second()
	var lerp_interval = direction / fps
	var lerp_position = global_transform.origin + lerp_interval
	
	camera.set_as_top_level(true)
	camera.global_transform.origin = camera.global_transform.origin.lerp(lerp_position, 20 * delta)
	camera.rotation.y = viewrotation_y
	camera.rotation.x = viewrotation_x
