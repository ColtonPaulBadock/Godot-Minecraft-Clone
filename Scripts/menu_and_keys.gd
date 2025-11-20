extends Node3D


func _ready():
	
	#Lock the mouse in the game window.
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN;
	
	pass;


func _process(delta):
	
	applicationInputs();
	
	pass;



#Manages specific keys reguarding the application.
func applicationInputs():
	
	#If the application kill button is pressed, close the game.
	if (Input.is_action_pressed("kill_application")):
		get_tree().quit();
		pass;
	
	pass;
