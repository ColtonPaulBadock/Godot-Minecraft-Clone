#This script manages the world list menu
#inside of the world selection menu.
#The World List will hold all created/saved worlds
#and house a button
#to create a new world

extends Node

#PackedStringArray holding the names of all
#saved worlds.
var save_worlds : PackedStringArray;



#Infinite application loop.
func _process(delta: float) -> void:
	
	pass;


#Runs when node is created
func _ready() -> void:
	
	#Displays all worlds in the "Saves" directory.
	#This will be all user created worlds.
	displayWorlds();
	
	pass;


#Displays all world saves under "WorldList"
#as buttons. Once clicked, we intend for these buttons
#to populate "WorldOptions" menu with the name,
#seed and other related data to the world.
#BETA: For earlier versions of the game,
#clicking the world will just load it.
func displayWorlds():
	
	#Get the names of all worlds in the default world save folder and store
	#there names in the "save_worlds" list.
	save_worlds = DirAccess.get_directories_at(WorldSaveSystem.default_world_save_path);
	
	#Loop through all the world saves and create clickable
	#instances of them in the WorldListMenu that
	#when clicked will boot that world.
	for world in save_worlds:
		
		#Instance of the world in the "WorldListContainer"
		#This instance is a button and will be costomized
		#for said world with its name, and an action that
		#will boot its associated world when pressed (associated
		#world by the same name)
		var worldList_worldInstance : Button;
		
		#This variable is a callable, which holds the function
		#name and the args that will be applied when a world
		#save is pressed. Here we intend to bind
		#the worlds name to this callable, to be a argument
		#to the world launching system.
		var onWorldClick : Callable;
		
		#Create a empty button, which will be displayed in the
		#"WorldListContainer" under world list. When clicked
		#this button will launch the name of the world associated with it
		worldList_worldInstance = Button.new();
		#Set the buttons name (in the hireachy) and visible text (as the world name);
		#Also set default font parameter.
		worldList_worldInstance.name = world;
		worldList_worldInstance.text = world;
		worldList_worldInstance.add_theme_font_size_override("font_size", 32);
		
		worldList_worldInstance.pressed.connect(test);
		
		#Add the world to the "WorldList" so it can be
		#selected and loaded into once pressed.
		$WorldListContainer.add_child(worldList_worldInstance);
		
		pass;
	
	pass;


func test():
	
	print("Hello");
	
	pass;
