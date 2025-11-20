extends CharacterBody3D


#Players speed and jump velocities
const SPEED = 3
const JUMP_VELOCITY = 6


func _process(delta):
	
	cameraManager();
	
	pass;




func _physics_process(delta: float) -> void:
	
	movementManager(delta);



#Manages the players movement
func movementManager(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("wasd_a", "wasd_d", "wasd_w", "wasd_s")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction: 
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide();
	
	pass;




#Manages the players camera and its inputs.
func cameraManager():
	
	#Default mouse spot; We use this spot to figure out 
	#how much the mouse moved, to move the camera.
	var mouse_spot : Vector2 = Vector2(300, 300); 
	#How much the mouse moved from default spot "mouse_spot"
	#for both x and y.
	var delta_mouse_y : int = 0;
	var delta_mouse_x : int = 0;
	#Mouse sensitivty
	var mouse_sensitivty : float = 0.005; #DEFAULT: 0.01
	
	
	
	#Figure out how much the mouse has moved for camera rotation
	delta_mouse_y = mouse_spot.y - get_window().get_mouse_position().y;
	delta_mouse_x = mouse_spot.x - get_window().get_mouse_position().x;
	
	#Rotate the player and piviot the camera up and down.
	rotate_y(delta_mouse_x * mouse_sensitivty);
	$CameraPivot.rotate_x(delta_mouse_y * mouse_sensitivty);
	
	#Set mouse back to default position "mouse_spot"
	Input.warp_mouse(mouse_spot);
	
	pass;
