#This script manages and runs the main menu.
#This script will run as a script of the node "MainMenu"
#and is the root node as the main menu becomes the main scene
#when open.
#So, when running "MainMenu" scene is running, this is the main scene.

extends Control


#The main scene of the game "World".
#When the play button is struck, we intend to run this scene,
#which is the gameplay scene.
var World : String = "res://Scenes/World.tscn"; #Path to the main menu




#Runs once on "MainMenu" scene startup.
func _ready() -> void:
	
	#Intialize properties for the main menu.
	#Setup variables, utility and anything needed.
	intiMainMenuProperties();
	
	#Intializes the actions of each button press.
	#Assigns functions to run when each button is pressed.
	#Basically sets up button outcomes.
	initButtonPressActions();
	
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



#Sets up the outcomes when a button is pressed
#Assigns a function to each button press.
#This function is run on main menu startup,
#intializing button functionality.
func initButtonPressActions() -> void:
	
	#When the "PlayButton" is pressed, function
	#"playGame" runs, switching to the game and
	#terminating the main menu.
	$Buttons/PlayButton.pressed.connect(playGame);
	
	#When the "QuitGameButton" is pressed,
	#function "quitGame" runs,
	#terminating the game.
	#Exits application entirely.
	$Buttons/QuitGameButton.pressed.connect(quitGame);
	
	pass;


#Quits the game, terminates application.
#Intended to be used by "Quit Game" button.
func quitGame() -> void:
	
	get_tree().quit(); #Terminates application.
	
	pass;


#Switches to the game, exiting the main menu
#and terminating the entire scene.
func playGame() -> void:
	
	#Set the main menu status to false,
	#so we don't go back to the main menu on startup of the game.
	#And so we can set ourselves to return to the main menu later
	global_variables.in_main_menu = false;
	
	get_tree().change_scene_to_file(World);
	
	pass;
