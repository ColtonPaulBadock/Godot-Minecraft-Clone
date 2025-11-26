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
	$"Play-CreateButton".pressed.connect(startWorldTemp);
	
	pass;

#A temporary function to start the game when "Play-CreateButton" is pressed
#This starts the world and passes the seed game itself.
#Intending to replace this with creating a save file, etc.
func startWorldTemp():
	
	#var testFile = FileAccess.open(global_variables.save_path + "\\FirstWorldSave\\testFile.txt", FileAccess.READ_WRITE);
	
	
	#Pass seed info to the global variables script
	global_variables.worldTerrainSeed = int($TerrainSeedTextBox.text);
	global_variables.worldBiomeSeed = int($BiomeSeedTextBox.text);
	
	#Switch to the main gameplay sceen "World"
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
