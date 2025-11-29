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
		
		#Create a empty button, which will be displayed in the
		#"WorldListContainer" under world list. When clicked
		#this button will launch the name of the world associated with it
		worldList_worldInstance = Button.new();
		#Set the buttons name (in the hireachy) and visible text (as the world name);
		#Also set default font parameter.
		worldList_worldInstance.name = world;
		worldList_worldInstance.text = world;
		worldList_worldInstance.add_theme_font_size_override("font_size", 32);
		
		#When the world is selected in the WorldListMenu (its of type button)
		#call "launchWorld()" to launch the world and pass it the
		#world name to launch, so that we begin loading into the world.
		worldList_worldInstance.pressed.connect(launchWorld.bind(world));
		
		#Add the world to the "WorldList" so it can be
		#selected and loaded into once pressed.
		$WorldListContainer.add_child(worldList_worldInstance);
		
		pass;
	
	pass;


#Launchs a saved world by the name
#name in the first argument "world".
#Exits the main menu and will begin loading the player into
#the world.
#-----
#ARGUMENTS:
#
#world -> name of the world to launch from the "Saves"
#folder.
func launchWorld(world : String):
	
	#Set the world save name we loaded into
	#in the WorldSaveSystem.
	#This is so we know which world we are running
	#and will pull data from it when getting player inventory,
	#loading fragments, or any save data related to this world.
	WorldSaveSystem.world_save_name = "\\" + world;
	
	print(WorldSaveSystem.world_save_name);
	print(WorldSaveSystem.user_path + WorldSaveSystem.default_world_save_path + WorldSaveSystem.world_save_name + WorldSaveSystem.world_save_terrain_folder);
	
	#Now that the world save name is set,
	#and we selected a world to load, we
	#will switch to the gameplay scene
	#"World" to play the game!.
	global_variables.in_main_menu = false;
	get_tree().change_scene_to_file("res://Scenes/World.tscn");
	
	pass;
