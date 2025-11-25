#This script manages and runs the main menu.
#This script will run as a script of the node "MainMenu"
#and is the root node as the main menu becomes the main scene
#when open.
#So, when running "MainMenu" scene is running, this is the main scene.

extends Control



#Runs once on "MainMenu" scene startup.
func _ready() -> void:
	
	#Intialize properties for the main menu.
	#Setup variables, utility and anything needed.
	intiMainMenuProperties();
	
	pass;


#Sets up main menu properties and
#parameters.
#Such as setting the mouse more to visible, etc.
func intiMainMenuProperties() -> void:
	
	#Set the mouse as visible, so the user can interact with and
	#Click on UI.
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	
	pass;



#Application infinite loop.
#Runs each frame.
func _process(delta: float) -> void:
	
	pass;
