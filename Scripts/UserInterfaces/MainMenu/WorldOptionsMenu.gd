#This script manages the world options menu for
#creating a new world.
#Here the user can create a new world and enter parameters for
#said new world.

extends Control

#The main node of the scene.
#We can use this to reference
#other nodes and call functions, paramters, etc
#from within them.
var mainSceneNode;


#Runs when node first enters the scene
func _ready() -> void:
	
	#Intialize instance of the root node
	#of the scene so we can reference other nodes
	#as needed.
	mainSceneNode = get_tree().get_root().get_node("MainMenu");
	
	#Intialize button actions,
	#so that buttons can be pressed
	initButtonPressActions();
	
	pass;


#Infinte loop, runs with application
func _process(delta: float) -> void:
	
	pass;


#Setup button actions when buttons
#are pressed.
func initButtonPressActions():
	
	#If "TitleScreenButton" is pressed, we will call
	#a function to return to the title screen
	$TitleScreenButton.pressed.connect(returnToTitleScreen);
	
	#If the create world button is pressed,
	#we will evaluate data inside the create world options
	#to start the new world!
	$"Play-CreateButton".pressed.connect(createNewWorld);
	
	pass;

#Creates a new world and begins loading the player
#in with parameters from WorldOptions menu, such
#as World name, entered seed, etc
func createNewWorld():
	
	#Inputs from the WorldOptionsMenu for the new world,
	#these values will hold data pulled from the text boxes,
	#before being pushed to "WorldSaveSystem.createNewWorld()"
	var worldName : String;
	var biomeSeed : int;
	var terrainSeed : int;
	
	#Pass seed info to the global variables script
	#-------
	#pass the worlds name to the WorldSaveSystem and have
	#it stored so we pull data from that save when loading
	#into the world and during runtime.
	terrainSeed = int($TerrainSeedTextBox.text);
	biomeSeed = int($BiomeSeedTextBox.text);
	worldName = $WorldNameTextBox.text;
	
	#If the world name is empty, fill it with
	#random numbers so its not empty
	if (worldName == ""):
		worldName = str(randi_range(0, 1000000));
	
	#Call the "createNewWorld()" utility from the WorldSaveSystem
	#so that we can create the a empty world and get ready to generate
	#all folders and meta-data for it based on entered seeds
	#and world name.
	#------
	#Since the world name is set, we will load this
	#new save/world when switching to the
	#world scene and out of the main menu
	#at ID: LAJSUHHI*(@#
	WorldSaveSystem.createNewWorld(worldName, terrainSeed, biomeSeed);
	
	#ID: LAJSUHHI*(@#
	#Switch to the main gameplay sceen "World".
	#Exit the main menu, we will load the save based on
	#the name "WorldSaveSystem.world_save_name"
	global_variables.in_main_menu = false;
	get_tree().change_scene_to_file("res://Scenes/World.tscn");
	
	pass;



#Returns to the title screen from
#the WorldOptionsMenu/WorldCreationMenu
func returnToTitleScreen():
	
	#Set the menu state to show the title
	#screen, so we can render it in an make sure its
	#all visible.
	mainSceneNode.state = mainSceneNode.menuState.TITLE_SCREEN;
	
	#Make the world selection menu invisible, so we can
	#not interact with it.
	mainSceneNode.get_node("WorldSelectionMenu").visible = false;
	
	pass;
