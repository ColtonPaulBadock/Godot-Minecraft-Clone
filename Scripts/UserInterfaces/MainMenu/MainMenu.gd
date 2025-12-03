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

#The current state we are in, in the main menu
#Uses the enum "menuState". Intialized in
#the "ready()" function.
var state;

#The menu state, it defines which menu
#state we are in.
#If we are in a specific menu, or doing a
#specific action, this specifies which
#state we are in
#
#STATES:
#
#TITLE_SCREEN: In the title screen, viewing the title, playbuttons, etc
#
#WORLD_SELECTION: In the world selection menu, with the create world options, etc
#
#TRANSITIONING_TO_WORLD_SELECTION: The state of switching to world selection
#
#CREATE_WORLD_MENU: In the menu to create the world.
enum menuState {
	TITLE_SCREEN,
	WORLD_SELECTION,
	TRANSITIONING_TO_WORLD_SELECTION,
}


#Runs once on "MainMenu" scene startup.
func _ready() -> void:
	
	#ENTRY POINT TO THE GAME
	#Check to make sure the default save/data
	#directory exists. If it doesn't
	#the game is likely being opened
	#on this device for the first time,
	#so we create the ".gratisexemptus" dir.
	#If it does already exist, we will simply do
	#nothing
	WorldSaveSystem.ensureDefaultSaveDirExists();
	
	#Set our current menu state to being in the main
	#menu viewing the title screen. With the playbuttons,
	#exit buttons, options, etc visible
	state = menuState.TITLE_SCREEN;
	
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
#Here we mainly evaluate which state of the main
#menu we are in, defined by variable "state".
#Allowing to progress and toggle throughout the
#main menu
func _process(delta: float) -> void:
	
	#If the current state of the menu is the
	#TITLE_SCREEN, then make sure we are on the title screen,
	#make sure all buttons visible, etc.
	if (state == menuState.TITLE_SCREEN):
		
		#If a component of the title screen,
		#such as "GameTitleName" used here is not
		#visible, then render the entire main
		#title screen in, making sure all components
		#are visible.
		if ($GameTitleName.visible == false):
			initTitleScreen();
			pass;
		
		pass;
	
	#If we are in the state to transition to the world selection
	#menu, I.E. state "TRANSITIONING_TO_WORLD_SELECTION" of the
	#menu states, we will make the world selection menu
	#visible, getting ride of any UI that doesn't belong there.
	if (state == menuState.TRANSITIONING_TO_WORLD_SELECTION):
		
		#Start the world selection menu up.
		#Under this function we will hide all UI,
		#buttons and anything related to the title screen,
		#and begin building the menu for the world creation/selection
		initWorldSelectionMenu();
		
		pass;
	
	#We are in the world selection menu.
	#Here we can wait in this loop everytime
	#and check for any conditions and such as the
	#player creates or selects a world, etc.
	if (state == menuState.WORLD_SELECTION):
		
		pass;
	
	pass;


#Removes previous menu from the scene and hides
#all nodes, getting the world selection menu visible
#so worlds can be selected, created, etc.
func initWorldSelectionMenu():
	
	#Start by assuming we where on the
	#title screen and kill (hide()) all UI, texts,
	#associated with it.
	closeTitleScreenUI();
	
	#Create the world selection menu,
	#so that we can select, delete, load or create worlds.
	#Spawns in the UI only, data will be loaded in by a
	#seperate function.
	initWorldSelectionUI();
	
	#Once the world selection menu has been intialized, we can
	#shift out of state "TRANSITIONING_TO_WORLD_SELECTION", and
	#enter "WORLD_SELECTION" state, to show we are in the
	#menu to select or create new worlds.
	state = menuState.WORLD_SELECTION;
	
	pass;


#Kills/closes the title screen UI.
#Hides/removes a buttons, title
#messages, texts, etc.
#This funciton is typically used when transitioning
#to the world creation or settings
#menus
func closeTitleScreenUI():
	
	#Hide all UI buttons on the title screen.
	$Buttons.visible = false;
	
	#Hide text, titles
	$GameTitleName.hide();
	
	pass;


#Creates/renders the world selection menus
#UI onto the screen. This UI will
#be used to select or create, or even load
#in worlds and edit them.
func initWorldSelectionUI():
	
	#Make all components of the world selection
	#menu visible.
	$WorldSelectionMenu.visible = true;
	
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


#Makes all UI on the title screen visible, so that we can
#see the game name, splash text, buttons, etc
func initTitleScreen():
	
	#Set all title screen UI to
	#be visible.
	$Buttons.visible = true;
	$GameTitleName.visible = true;
	$CopyrightNotice.visible = true;
	
	#Reset the splash text to a random text.
	$GameTitleName/SplashText.setSplashText();
	
	pass;


#Quits the game, terminates application.
#Intended to be used by "Quit Game" button.
func quitGame() -> void:
	
	get_tree().quit(); #Terminates application.
	
	pass;


#Updates the state of the main menu to "TRANSITIONING_TO_WORLD_SELECTION".
#This allows for the world selection menu to be brought in.
func playGame() -> void:
	
	#NOTE: Old code to hop right in!
	#Set the main menu status to false,
	#so we don't go back to the main menu on startup of the game.
	#And so we can set ourselves to return to the main menu later
	#global_variables.in_main_menu = false;
	#get_tree().change_scene_to_file(World);
	
	#Set the state to transitioning to the world selection menu.
	#The applicaton will detect this change in the main loop
	#and begin switching accordingly
	state = menuState.TRANSITIONING_TO_WORLD_SELECTION;
	
	pass;
