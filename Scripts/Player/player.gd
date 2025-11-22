extends CharacterBody3D


#Players speed and jump velocities
const SPEED = 3
const JUMP_VELOCITY = 6

#Instance of the players reach (line of sight/aim)
@onready var playerReach = get_node("CameraPivot/PlayerReach");
var objectPlayerIsLookingAt; #The object the player is looking at within there reach.

#Instance of the world.
@onready var world = get_tree().get_root().get_node("World");

func _ready() -> void:
	
	
	pass;


func _process(delta):
	
	cameraManager(); #Enable camera movement from the players mouse
	
	#Control the breaking and placing/interaction of objects throughout the world
	#from the player
	interactionManager(); 
	
	pass;




func _physics_process(delta: float) -> void:
	
	movementManager(delta);
	
	



#Controls the destruction and placing of objects, blocks, etc throughout the world from the player
func interactionManager():
	
	#Store a instance of the object the player is looking at within there reach
	#in "objectPlayerIsLookingAt", if they are not looking at a object
	#within reach, set "objectPlayerIsLookingAt" to null and exit this function.
	if (playerReach.is_colliding()):
		objectPlayerIsLookingAt = world.locateBlockAt(playerReach.get_collision_point());
	else:
		objectPlayerIsLookingAt = null;
		return;
	
	
	
	
	pass;



#Manages the players movement
func movementManager(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if (Input.is_action_just_pressed("jump") && is_on_floor() && global_variables.inputAllowed == true):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("wasd_a", "wasd_d", "wasd_w", "wasd_s");
	#If player input is disabled, return a vector2 with no movement, effectively disabling player movement
	#"input_dir" is set as a zero Vector2
	if (global_variables.inputAllowed == false):
		input_dir = Vector2(0.0, 0.0);
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
	
	#If Input is disabled, skip this function
	if (global_variables.inputAllowed == false):
		return;
	
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
