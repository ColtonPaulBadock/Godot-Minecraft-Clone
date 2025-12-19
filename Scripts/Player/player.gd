extends CharacterBody3D


#Players speed and jump velocities
const SPEED = 4;
const JUMP_VELOCITY = 8;

#Instance of the players reach (line of sight/aim)
@onready var playerReach = get_node("CameraPivot/PlayerReach");
var objectPlayerIsLookingAt; #The object the player is looking at within there reach.

#Instance of the world.
@onready var world = get_tree().get_root().get_node("World");

#Instance of the players crosshair
#Helps the player aim
@onready var crosshair = $CameraPivot/Camera3D/Crosshair;

#Istance to the players toolbelt/backpack (inventoru)
@onready var toolbelt = $CameraPivot/Camera3D/ToolBeltCanvasLayer/ToolBelt;

#Instance of the players camera
@onready var cameraPivot = $CameraPivot;

#instance of the DebugWindow for logging
var debugWindow;

#this variable holds the id
#of the object/block they are holding
var playerObjectHeld_id = 0;

#This is the debug variable to disable the mouse
#locking in the window, and to not track the mouses inputs.
#If this variable is true, this will take effect.
var debug_remove_mouse_locked_in_window : bool = false;


func _ready() -> void:
	
	#Setup the instance of the debug window so we can log
	#the output box if needed
	debugWindow = get_tree().get_root().get_node("World/Player/CameraPivot/Camera3D/DebugWindowCanvasLayer/DebugWindow/DebugWindowPanel/OutputBoxPanel/OutputBox")
	
	#Setup the users crosshair, which assists with aiming
	#Set the crosshair to appear in the middle of the screen
	#Intialize other properties here if needed
	initCrossHair();
	
	pass;


func _process(delta):
	
	cameraManager(); #Enable camera movement from the players mouse
	
	#Control the breaking and placing/interaction of objects throughout the world
	#from the player
	interactionManager(); 
	
	#Allow the player to select which block they are holding
	#Use the "tool_belt_up" or "tool_belt_down" to scroll
	#indexes in the tool_belt to allow the player to
	#select different items in said tool_belt.
	tool_belt_controller();
	
	pass;



#Manage the physics with the player
#Allows for player movement logic
func _physics_process(delta: float) -> void:
	
	movementManager(delta);
	

#Sets up the players crosshair in the center of the screen
#This helps assist with aiming, etc
#Takes the screen size and divides both X and Y axis's by 2 to find a
#center point of the screen.
func initCrossHair() -> void:
	
	#Set the x and y position of the crosshair in the center of the players screen.
	#Take the Displays X and Y size, divide these axis's by 2 to find the center
	#point of each axis.
	crosshair.position.x = (DisplayServer.screen_get_size().x) / 2;
	crosshair.position.y = (DisplayServer.screen_get_size().y) / 2;
	
	pass;



#Allows the player to interact with blocks,
#and objects around them.
func interactionManager():
	
	#If the player presses the "place" input, then we want to take the
	#position the raycast3d hits, apply the raycast bounce behaviour
	#take the ID of the block they want to place and place the block
	#at there bounced raycast endpoint if no block is there
	if (Input.is_action_just_pressed("place") && global_variables.inputAllowed == true):
		
		#If the object/block was successfully placed,
		#this value will be set as true, we then use this
		#value to play the block placing tone/sound.
		var blockPlacedSuccessfully = false;
		
		#Add the block id of the 2nd argument to the world
		#at the position of the raycast end point "PlayerReach"
		#assuming no block is there, with the bounce RayCast
		#behaviour applied from function applyRaycastBehaviour()
		blockPlacedSuccessfully = world.addBlock(applyRaycastBehviour(playerReach.get_collision_point(), "bounce"), playerObjectHeld_id);
		
		#If the block was successfully placed by the player,
		#I.E. no obstruction, then play the block placing tone/sound,
		if (blockPlacedSuccessfully == true):
			
			#Get the instance of the audio manager from global
			#variables, the play the "placeObject" sound.
			#We are assuming at this point that the block/object
			#was successfully placed.
			#global_variables.AudioManager.placeObject.play();
			pass;
		
		pass;
	
	
	#If the player presses the "strike" keybind, we want to take the
	#object/thing they are looking at and strike/destroy it.
	#We want to use the penetration behaviour on the "PlayerReach"
	#(RayCast3D) to enter inside the object, to truely detect we hit
	#it. Then we will use the appropriate method (removeBlockAt, or a attack
	#method) to carry out the action.
	if (Input.is_action_just_pressed("strike") && global_variables.inputAllowed == true):
		
		#THis variable holds a value indicating
		#if we successfully destroyed a block/object.
		#If we did, its true, else its false.
		#We use this to play the audio sound for breaking a block/object
		#This variable is false by default, and is not true
		#till we have removed the block/object successfully.
		var blockSuccessfullyRemoved : bool = false;
		
		#Call the removeBlock() function from "world.gd" in the world
		#scene. This will try to remove a block from the world.
		#This applys the rayCastBehaviour() function to apply behaviour
		#of penetrate.
		#Sends the position within the block we want to remove.
		#"blockSuccessfullyRemoved" will be true if a block/object is removed
		#else, it will be false.
		blockSuccessfullyRemoved = world.removeBlock(applyRaycastBehviour(playerReach.get_collision_point(), "penetrate"), "PLAYER");
		
		
		
		#Here we want to play the audio of a block/object breaking.
		#If a object/block was successfully removed (blockSuccessfullyRemoved
		#is true), then play the sound, else do not.
		if (blockSuccessfullyRemoved == true):
			
			#Get the instance of the audio manager from global
			#variables, the play the "breakObject" sound.
			#We are assuming at this point that the block/object
			#was successfully destroyed.
			#global_variables.AudioManager.breakObject.play();
			pass;
		
		pass;
	
	
	
	pass;



#Allows the player to select blocks using the keybinds
#"inventoryDown" and "inventoryUp".
#This block selector is momentary and will be relaced
#with a inventory and item selection system later.
func tool_belt_controller() -> void:
	
	#Change the block we are holding using the "inventoryUp"
	#and the "inventoryDown" inputs.
	#If the input is "inventoryUp" we want to up (++) the ID
	#of the block the player is holding.
	#Conterary, if the input is "inventoryDown" we want to
	#drop (--) the ID of the block/object the player is holding.
	#"playerObjectHeld_id" represents the block/object the
	#player is holding.
	if (Input.is_action_just_pressed("tool_belt_up")):
		playerObjectHeld_id += 1;
	elif (Input.is_action_just_pressed("tool_belt_down")):
		playerObjectHeld_id -= 1;
	
	#Right now, the game assumes a player is always holding
	#a object to place, later this will be changed.
	#For now, if "playerObjectHeld_id" is below 0 (its not a valid block
	#id) then reset it to the max block ID available. If 
	#"playerObjectHeld_id" is above the max block ID available,
	#then set it back to ID 0.
	if (playerObjectHeld_id > global_variables.maxBlockId): #If the block ID the player is holding is above the max possible value value, set the block ID the player is holding to 0.
		playerObjectHeld_id = 0;
	elif (playerObjectHeld_id < 0):
		playerObjectHeld_id = global_variables.maxBlockId; #If the block ID the player is holding is less than 0 (which is illegal), set it to the max value of the block_table array.
	
	pass;



#Applys behaviour to the players raycast, such as bouncing
#of a object by "global_variables.playerReachPenetration" or
#traveling "global_variables.playerReachPenetration" into the
#object before returning the collision point, based on the
#set behaviour defined by argument "type".
#
#-Arguments-
#
#pos = intial collision position of player raycast
#
#type = Bounce, Penetrate, etc. The type of raycast behvaiour
#     -"bounce" -> bounces "global_variables.playerReachPenetration" distance
#                  off the object before returning the position
#
#     -"penetrate" -> penetrates the object "global_variables.playerReachPenetration"
#                     distance before returning collision position
#
func applyRaycastBehviour(pos : Vector3, type : String) -> Vector3:
	
	#If the behaviour for the raycast is of type "bounce" we want
	#to reflect the raycast of the block/objects surface
	#and have it travel "global_variables.playerReachPenetration"
	#distance off the blocks surface
	if (type == "bounce"):
		
		#We need to figure out which direction to bounce the raycast
		#off the block, based on were we detected to place the
		#block/object (where the raycast hit) and were the player
		#is conterary to this. If the player is further down the x axis (-)
		#from the block, we want to move closer to the player so we bounce
		#toward the player down the x axis. If the player is up the x-axis
		#from the block, bounce the raycast up the axis. This logic
		#is true for the z axis as well.
		##The Y access is a bit different
		#Instead of using the players position, we use the position
		#of the players camera pivot "CameraPivot", so that the
		#math is inline with the players view.
		
		#Apply raycast behaviour to the X corrdinate
		if (position.x < pos.x):
			pos.x -= global_variables.playerReachPenetration;
		elif (position.x > pos.x):
			pos.x += global_variables.playerReachPenetration;
		
		#Apply raycast behaviour to the Z corrdinate
		if (position.z < pos.z):
			pos.z -= global_variables.playerReachPenetration;
		elif (position.z > pos.z):
			pos.z += global_variables.playerReachPenetration;
		
		#Apply raycast behaviour to the Y corrdinate
		if (position.y + $CameraPivot.position.y > pos.y):
			pos.y += global_variables.playerReachPenetration;
		elif (position.y + $CameraPivot.position.y < pos.y):
			pos.y -= global_variables.playerReachPenetration;
		
		pass;
	
	
	#If the behaviour for the raycast is to penetrate, we want to take the
	#position the raycast hits and depending on where the player is standing,
	#travel in the opposite corrdinate direction into the block/object.
	#Travels "global_variables.playerReachPenetration" distance into the surface
	#/block it hits
	#lets say the player is at a lesser X and a lesser Z corrdinate
	#than the block to penetrate, we take the position of the "PlayerReach"
	#(RayCast3D) collision point. Since the player is at a lesser X, we want to
	#add to the x, moving away from the player (penetrating the block) via the X
	#corrdinate. The z will use this same logic.
	if (type == "penetrate"):
		
		#Apply raycast behaviour to the X corrdinate
		if (position.x < pos.x):
			pos.x += global_variables.playerReachPenetration;
		elif (position.x > pos.x):
			pos.x -= global_variables.playerReachPenetration;
		
		#Apply raycast behaviour to the Z corrdinate
		if (position.z < pos.z):
			pos.z += global_variables.playerReachPenetration;
		elif (position.z > pos.z):
			pos.z -= global_variables.playerReachPenetration;
		
		#Apply raycast behaviour to the Y corrdinate
		if (position.y + $CameraPivot.position.y > pos.y):
			pos.y -= global_variables.playerReachPenetration;
		elif (position.y + $CameraPivot.position.y < pos.y):
			pos.y += global_variables.playerReachPenetration;
		
		pass;
	
	#Once the behaviour has been applied to the
	#players raycast, return "pos" which is the raycast
	#position (Vector3) inputed into the function intially
	#with its requested behavioural modifications.
	return pos;






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
	
	
	#Here is the manager for the players camera via mouse movements.
	#Compared to the last frame, figure out how much the mouse moved from its
	#"mouse_spot" corrdinates, and move the mouse based on this factor, times
	#sensitivity.
	#Then set the mouse back to its "mouse_spot" for the next frame.
	#However, if "debug_remove_mouse_locked_in_window" is true, then
	#don't lock the mouse on "mouse_spot" in the window, don't track the mouses
	#movement from "mouse_spot". This is used for debugging purposes.
	if (debug_remove_mouse_locked_in_window == false):
		#Figure out how much the mouse has moved for camera rotation
		delta_mouse_y = mouse_spot.y - get_window().get_mouse_position().y;
		delta_mouse_x = mouse_spot.x - get_window().get_mouse_position().x;
		
		#Rotate the player and piviot the camera up and down.
		rotate_y(delta_mouse_x * mouse_sensitivty);
		$CameraPivot.rotate_x(delta_mouse_y * mouse_sensitivty);
		
		#Prevent illegal camera positions
		preventIllegalCameraPosition();
		
		#Set mouse back to default position "mouse_spot"
		Input.warp_mouse(mouse_spot);
	
	pass;


#Prevent the camera from entering illegal positions of rotation.
#If the player camera enters a illegal rotation, go to its max or min position allowed
#as defined in "global_variables" depending on wether the min or max rotation
#was overshot.
func preventIllegalCameraPosition() -> void:
	
	#If the players camera position overshots the max position allowed, move the camera back to the max position
	#same logic for if the minimum is overshot, but for the minimum value
	if (cameraPivot.rotation.x > global_variables.playerCameraMaxLookUp):
		cameraPivot.rotation.x = global_variables.playerCameraMaxLookUp;
	elif (cameraPivot.rotation.x < global_variables.playerCameraMinLookDown):
		cameraPivot.rotation.x = global_variables.playerCameraMinLookDown;
		pass;
	
	pass;
