#This script manages the world list menu
#inside of the world selection menu.
#The World List will hold all created/saved worlds
#and house a button
#to create a new world

extends Node



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
	
	
	
	pass;
