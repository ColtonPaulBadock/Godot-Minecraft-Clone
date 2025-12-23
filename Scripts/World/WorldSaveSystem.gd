#This script manages and interprets all world saves
#It contain utilities to read, save and index
#any world save file.

extends Node

#Instance of the save file
#for the players inventory.
var inventory_save_file : FileAccess;

#The save name (this will be the worlds name)
#Default name is "DEBUG_WORLD". If a world by
#this name is created, something went wrong??
var world_save_name : String = "\\DEBUG_WORLD";

#Stores the users username and path,
#EXAMPLE: "C:\users\<USERNAME>\
var user_path : String = OS.get_environment("USERPROFILE");

#The default world save path.
#Which points to the ".gratisexemptus" folder and the
#"Saves" folder inside it.
var default_world_save_path : String = user_path + "\\AppData\\Roaming\\.gratisexemptus\\Saves";

#Default path from the worlds save folder
#into the "terrain" folder, holding all
#files within the area save format.
#------
#"world_save_meta_folder" is the default meta
#data folder
var world_save_terrain_folder : String = "\\terrain";
var world_save_meta_folder : String = "\\meta";

#The current fragment we are loading from save
#data. This is set by "loadFragment" and an instance
#of the fragment to try and load.
#-------
#"fragmentDataPosition" is the index of the data we are working with.
#it will point to the starting position of the next unread data
#for the fragment in "feedFragment()", other utilities.
#-------
#"loadingFragment_data" is the data as a String from
#"loadingFragment"
var loadingFragment : FileAccess;
var loadingFragment_data : String;
var fragmentDataPosition : int;

#Data for loading the player
#inventory from the previous save
#--------
#"inventoryDataPosition" is the current position
#(index of the save data) for the player inventory
#we are at while loading items.
var inventoryDataPosition : int;


#Intializes stuff with the WorldSaveSystem.
func _ready() -> void:
	pass;


#Laymans: Call this function to get a fragment
#ready to be feed through by "feedFragment"
#-----
#Gets a fragment's data stored in "loadingFragment"
#so that we can feed it "fragment.gd" or other systems
#to load a fragment block by block from save files.
func loadFragment(fragment):
	
	#The file path where the fragment
	#is stored (including area save file)
	var path : String;
	
	#The frag tag associated with the fragment,
	#this is where data will be stored
	#for "fragment"
	var fragTag : String;
	
	#These variables are used to compute
	#the fragtags begginging point so we
	#can find where the data starts.
	#These are used to set "fragmentDataPosition"
	#so we know where in the data we are when
	#using feedFragment() later.
	#var fragTagStartIndex : int = 0;
	#var fragTagEndIndex : int;
	#var fragTagLength : int;
	
	
	#Check to see if a fragment of "fragment" is even
	#in the save files, if it is not, return -1.
	if (checkIfFragmentIsSaved(fragment) == false):
		return -1;
	
	#Get the path the fragment is stored at
	#in the save files.
	path = getFragmentSaveFilePath(fragment);
	
	#Get the fragtag for "fragment" so we can
	#find out where the fragment is stored
	#inside the save file "path".
	fragTag = getFragmentTag(fragment, false);
	
	#Open the area save file
	#for the fragment we are trying
	#to load.
	loadingFragment = FileAccess.open(path, FileAccess.READ);
	
	#Load the save data from
	#"loadingFragment" as a String into
	#"loadingFragment_data" universal script variable
	#so we can parse the data from wherever using
	#"feedFragment()" and other utilities
	#in the script.
	loadingFragment_data = loadingFragment.get_as_text();
	
	#Reset "fragmentDataPosition" to 0, so we start at the top
	#of the save data
	fragmentDataPosition = 0;
	#Set the start position (index) of the data
	#relating to "fragment" in "fragmentDataPosition"
	#so we are at the start of the data, and can keep
	#track of where we are in the data as we
	#move through it later in "feedFragment()", other
	#utilities;
	#-----
	#Laymans Terms: We right after "{" in "fragmentTag + "{}"",
	#fragmentDataPosition points to this
	#------
	#Find "fragTag" and return its position.
	#The add the length of "fragTag" + 1, so account
	#for the fragTag's length and '{' to get the data.
	fragmentDataPosition = loadingFragment_data.find(fragTag);
	fragmentDataPosition += fragTag.length() + 1;
	
	#We now have all save info loaded into
	#"loadingFragment_data" thats associated with
	#"fragment" and we found the fragTag and
	#the begining index of the data. We can
	#use "feedFragment()" to feed blocks through
	#one at a time.
	
	pass;


#Returns a block from the current fragment "loadingFragment"
#Each time its called, the next block in the data/save is
#returned. Once we hit the end of the data, "-1" will
#be returned.
func feedFragment():
	
	#Instance of the block/object/thing
	#we are loading from save data. Each index holds
	#a specific value related to the item.
	#-----
	#INDEXS:
	#0 = x position (local to fragment)
	#1 = y position (local to fragment)
	#2 = z position (local to fragment)
	#3 = block_id (id of the object/block)
	var object = [0, 0, 0, 0];
	
	#The current character/char we are retireveing/processing
	#from the save data.
	var currentCharacter : String;
	
	#The current value we are converting to
	#data points from ID: 8298379187398719 for
	#the object/block we are loading from save dara
	var currentValue : String;
	
	#The total corrdinates we have loaded so far.
	#For each cord (x, y and z) we increment this
	#variable by 1 so we know which one we are currently
	#on when pulling the corrdinates from the save data.
	var corrdsLoaded : int = 0;
	
	
	#ID: 8298379187398719
	#Data points we need to pull from the
	#save data for the block/object
	#All "pos" variables should be local
	#corrdinates to the fragment they exist in.
	var x_pos : float;
	var y_pos : float;
	var z_pos : float;
	var id : int; #ID of the block/Object/Whatever
	
	
	#Check to make sure we haven't hit the end of the fragment
	#data. If we have hit the end "}", we will return -1
	if (loadingFragment_data.substr(fragmentDataPosition, 1) == "}"):
		return -1;
	
	#The following is the algorithm to derive "x_pos",
	#"y_pos:, "z_pos" and "id" for the block/objects
	#we are loading in
	#------
	#Start by getting "x_pos"
	while (corrdsLoaded != 3):
		while (loadingFragment_data.substr(fragmentDataPosition, 1) != ","):
			
			#Get the current character we are on
			#Store it in "currentCharacter"
			currentCharacter = loadingFragment_data.substr(fragmentDataPosition, 1);
			
			#Update the "fragmentDataPosition" which moves us
			#to be ready for the next character, next loop.
			fragmentDataPosition = fragmentDataPosition + 1;
			
			#If we see the '(' marking the begining
			#of the data, we will continue past it, to the next value
			if (currentCharacter == "("):
				continue;
			
			#We must have a legitmate value, 
			#add it to the end of the current value.
			#We will keep doing this till we see ","
			currentValue = currentValue + currentCharacter;
			pass;
		
		#Increment the data position to move past ",",
		#so we have the next raw data.
		fragmentDataPosition = fragmentDataPosition + 1;
		
		#depending on which corrdinate we are deriving
		#from the save data, we will store it in its respected value/corrdinate
		#and will then reset the "currentValue" for the next value
		if (corrdsLoaded == 0):
			x_pos = currentValue.to_float();
		elif (corrdsLoaded == 1):
			y_pos = currentValue.to_float();
		elif (corrdsLoaded == 2):
			z_pos = currentValue.to_float();
		
		#Reset the current value (for the next value).
		#Increment "corrdsLoaded" by one so we
		#know which one we are pulling from the save data.
		currentValue = "";
		corrdsLoaded = corrdsLoaded + 1;
		
		pass;
	
	
	
	#Get the block/object ID as the last data type we need.
	while (loadingFragment_data.substr(fragmentDataPosition, 1) != ")"):
		
		#Get the current character we are on
		#Store it in "currentCharacter"
		currentCharacter = loadingFragment_data.substr(fragmentDataPosition, 1);
		
		#Add the current character to the current value
		currentValue = currentValue + currentCharacter;
		
		#Update the "fragmentDataPosition" which moves us
		#to be ready for the next character, next loop.
		fragmentDataPosition = fragmentDataPosition + 1;
		
		pass;
	
	#Set the id of the block/object
	#from the last piece of data in the blocks save
	#in the fragments data.
	#Increment "fragmentDataPosition" so we are at "(" for
	#the next piece of block data in the fragment data.
	id = currentValue.to_int();
	fragmentDataPosition = fragmentDataPosition + 1;
	
	#Build instance of the block before returning it
	object[0] = x_pos;
	object[1] = y_pos;
	object[2] = z_pos;
	object[3] = id;
	
	#Return the block/object with its position, id, etc
	return object;



#Checks the position "world_pos" to see if a save file
#holds data for a fragment at said "world_pos" if so, true
#is returned. If a fragment can't be found in save files
#matching said "world_pos" position, false is returned.
#
#----
#Arguments:
#
#world_pos -> World position to check for a fragment
#in the save files
#
#
#----
#Returns (boolean):
#
#true -> if a fragment exists at "world_pos" position in the save files
#
#false -> if a fragment doesn't exist at "world_pos" position in the save files
func checkIfFragmentIsSaved(fragment):
	
	#Boolen status and the return of this function.
	#If true, the fragment was found in the save files,
	#else it wasn't found.
	var fragmentFound : bool;
	
	#The file path of the save file
	#that the fragment will be in.
	#If its not there, it surely couldn't exist?
	var path : String;
	
	#If the file is found (not nessically the fragment)
	#then we will set this boolean true and check
	#inside its possible file to see if the fragment exists
	#If it does, then we will return true with this entire function
	var saveFileFound : bool = false;
	
	#Boolean status as to if a fragment was found at
	#"world_pos" in the save files.
	fragmentFound = false;
	
	
	#First we check to see if a save file for the fragment exists.
	#If so, "saveFileFound" will become true, allowing us to move on
	#and check said save file for the fragments existance.
	saveFileFound = checkIfSaveFileExists(fragment);
	
	#If the save file was found, get its path
	#which we will then use to check if the fragment
	#exists in said save file.
	#If the save file isn't even in existance, we will exit
	#this function returning false
	if (saveFileFound == true):
		path = getFragmentSaveFilePath(fragment);
	elif (saveFileFound == false):
		fragmentFound = false;
		return fragmentFound;
	
	#The save file was determined to exist, we have its path
	#stored in string "path", now lets search for fragment "fragment"
	#in the respected save file at "path" to see if the fragment exists.
	#If it doesn't exist, we will return false. If it exists, we return true.
	fragmentFound = checkIfFragmentInSaveFile(path, fragment);
	
	return fragmentFound;


#Checks to see if the fragment in argument one
#"fragment" has a save file. If so, returns true, else false.
#NOTE: If it has a save file, that doesn't mean its
#in said save file.
#--
#Arguments:
#
#"fragment" -> The fragment we want to see if it has a save file
func checkIfSaveFileExists(fragment):
	
	#The fragment area corrdinates relating to
	#the file the fragment will be in, in the area save
	#format.
	var x_area : int;
	var z_area : int;
	
	#The file path of the save file
	#that the fragment will be in.
	#If its not there, it surely couldn't exist?
	var path : String;
	
	#If the file is found (not nessically the fragment)
	#then we will set this boolean true and check
	#inside its possible file to see if the fragment exists
	#If it does, then we will return true with this entire function
	var saveFileFound : bool = false;
	
	#Determine which fragment area the fragment would be in
	#so we can follow the fragment area save format
	#conventions of "x.z.gewd"
	#-----
	#Since a fragment area is in fragment groups 8 x 8, extending
	#from 0, 0 of the world, we can take the world position
	#of each axis and divide it by (fragmentSideLength (which is 10) * fragmentAreaSideLength (which is 8)) to get a
	#decimal, and we round it down to get the x or z area corrdinate. So if
	#we where at (35, 45), we would get decimals for both axis's, and we simply
	#round down to get the corrdinate of the area, effectively eliminating the decimal.
	x_area = floor(fragment.global_position.x / (global_variables.fragmentSideLength * global_variables.fragmentAreaSideLength));
	z_area = floor(fragment.global_position.z / (global_variables.fragmentSideLength * global_variables.fragmentAreaSideLength));
	
	#Now we have the x and z area corrdinates
	#of the fragment area, we need to search
	#for a save file that has these same corrdinates
	path = default_world_save_path + world_save_name + world_save_terrain_folder + "\\" + str(x_area) + "." + str(z_area) + ".gewd";
	
	#Now that we found the file path the fragment
	#would exist in, lets see if said file
	#exists. If it does, then we set "saveFileFound"
	#as true and can then search the save file for its
	#existance. If the save file isn't found, the fragment
	#technically shouldn't exist and we can return false
	#with this entire function.
	if (FileAccess.file_exists(path)):
		saveFileFound = true;
		pass;
	
	
	return saveFileFound;


#Takes "fragment" (instance of a fragment) and returns
#its save file path as a string.
func getFragmentSaveFilePath(fragment):
	
	#The fragment area corrdinates relating to
	#the file the fragment will be in, in the area save
	#format.
	var x_area : int;
	var z_area : int;
	
	#The file path of the save file
	#that the fragment will be in.
	#If its not there, it surely couldn't exist?
	var path : String;
	
	#Determine which fragment area the fragment would be in
	#so we can follow the fragment area save format
	#conventions of "x.z.gewd"
	#-----
	#Since a fragment area is in fragment groups 8 x 8, extending
	#from 0, 0 of the world, we can take the world position
	#of each axis and divide it by (fragmentSideLength (which is 10) * fragmentAreaSideLength (which is 8)) to get a
	#decimal, and we round it down to get the x or z area corrdinate. So if
	#we where at (35, 45), we would get decimals for both axis's, and we simply
	#round down to get the corrdinate of the area, effectively eliminating the decimal.
	x_area = floor(fragment.global_position.x / (global_variables.fragmentSideLength * global_variables.fragmentAreaSideLength));
	z_area = floor(fragment.global_position.z / (global_variables.fragmentSideLength * global_variables.fragmentAreaSideLength));
	
	#Now we have the x and z area corrdinates
	#of the fragment area, we need to search
	#for a save file that has these same corrdinates
	path = default_world_save_path + world_save_name + world_save_terrain_folder + "\\" + str(x_area) + "." + str(z_area) + ".gewd";
	
	
	return path;




func checkIfFragmentInSaveFile(path, fragment):
	
	#The file we are opening to search for the fragment
	#(assuming we find a matching file)
	var save_file : FileAccess;
	
	#The contents of "save_file" but as a string
	#loaded into RAM (so we can index/search the file)
	var save_file_as_text : String;
	
	#Boolean as to weather "fragment" can be found 
	#in the save file at "path"; This is returned by
	#the function.
	#false -> fragment not in save file
	#true -> fragment is in save file
	var fragmentInSaveFile : bool = false;
	
	#The tag the fragment will be stored under
	#in the save file
	var fragment_save_file_tag : String;
	
	
	
	#Open the save file that could possibly contain the fragment
	save_file = FileAccess.open(path, FileAccess.READ);
	
	
	#If the save file can't be opened,
	#then we return false, as the file that should
	#have had it somehow doesn't exist anymore since
	#we previously checked.
	if (save_file == null):
		fragmentInSaveFile = false;
		return fragmentInSaveFile;
	
	
	#Take the contents of "save_file" and store
	#them in "save_file_as_text" as a String, so that
	#the text is present in RAM and we can index/read
	#through said text.
	save_file_as_text = save_file.get_as_text();
	
	#Now we need to determine the fragments tag it will be under in the
	#save file. Tags use the format "<worldX, worldZ { }", so
	#we just take the fragments worldX and worldZ corrdinates
	#from "world_pos" argument to this function, derived from the
	#"global_position" Vector of the fragment
	fragment_save_file_tag = "<" + str(int(fragment.global_position.x)) + "," + str(int(fragment.global_position.z));
	
	#Now we search for the fragment tag "fragment_save_file_tag"
	#in "save_file_as_text" (the contents of the save file we identified
	#the fragment must be in). If we find said tag, the fragment exists!
	#We set "fragmentFound" to true and will return the status of finding it.
	#If the text isn't found, the fragment theroetically hasn't been rendered and
	#the "fragmentFound" remains false.
	if save_file_as_text.contains(fragment_save_file_tag):
		fragmentInSaveFile = true;
		pass;
	
	#Close the save file
	save_file.close();
	
	return fragmentInSaveFile;



#This function takes the argument "fragment"
#which is an instance of a fragment and writes it into
#save files.
#
#----
#Arguments:
#
#fragment -> instance of the fragment to be saved
func saveFragment(fragment):
	
	#Instance of the save file we will
	#be saving the fragment to
	var save_file : FileAccess;
	
	#The save data as a string from
	#"save_file".
	var save_data : String;
	
	#The path for the save file
	#we are writing the fragment into.
	var path : String;
	
	#The fragment tag we will find to store
	#data in the file for the fragment
	var fragTag : String;
	
	#The position (int) in the file to where
	#we can start writing data and where said data
	#begins inside the fragment tag.
	#The fragmentDataEndIndex is also here,
	#which marks the index in which data ends for the
	#"fragment" in the save file.
	var fragmentDataStartIndex : int;
	var fragmentDataEndIndex : int; 
	
	#This variable holds block info for the
	#postiion and block ID which is going
	#to be inserted into the fragTag area
	#of the save file for "fragment".
	#Example: (1,20,9,10)
	var blockData : String;
	
	#Flow chart for functions operation:
	#if (fileExists):
	#	if (fragmentExistsInFile):
	#		FIND TAG IN FILE
	#		WRITE SAVE
	#	else:
	#		CREATE FRAGMENT IN FILE
	#		WRITESAVE
	#else:
	#	CREATE FILE
	#	CREATE FRAGMENT IN FILE
	#	FIND TAG IN FILE
	#	WRITESAVE
	
	#Check to see if a save file exists for the
	#fragment "fragment"
	#If it exists, we need to check to see if the fragment is in the save file
	#If it doesn't exist, we need to create a save file for the fragment
	if (checkIfSaveFileExists(fragment) == true):
		
		#We determined the file that would house
		#the fragment exists, so set "path" as the
		#path pointing to the file.
		path = getFragmentSaveFilePath(fragment);
		
		#Now we check to see if the fragment exists in
		#the path, if it doesn't we will need
		#to create an entry for the fragment in the
		#Save Area file.
		if (checkIfFragmentInSaveFile(path, fragment) == true):
			#If the fragment tag exists, we don't need to
			#do anything here and can move on to writing data to
			#the fragment in the save file.
			pass;
		else:
			#If a fragment tag was not found in the save file,
			#but the save file exists, then we need to create
			#a fragment tag in the save file at "path"
			#for "fragment"
			createFragmentTag(path, fragment);
	else:
		
		#We determined no save file exists, so we need to generate a save
		#file and a fragment tag in the save file.
		createSaveFile(fragment);
		createFragmentTag(path, fragment);
		path = getFragmentSaveFilePath(fragment);
		
		pass;
	
	#NOTE: DEBUG
	var debug = false;
	if (fragment.blocks.is_empty() != true && debug == true):
		print("I see this fragment contains blocks: " + str(fragment.global_position.x, ", ", fragment.global_position.z));
	
	#We know the file exists, and we know it has
	#a fragment tag at this point.
	#We now want to locate the tag, and
	#override everything in {} with the new save data
	#for the fragment.
	fragTag = getFragmentTag(fragment, false);
	
	#NOTE: DEBUG
	if (fragment.blocks.is_empty() != true && debug == true):
		print("The frag tag is: ", fragTag);
	
	#Open the save file, this will be so we
	#can extract all data from it, and
	#write all data back to it once we are
	#done manipulating it.
	save_file = FileAccess.open(path, FileAccess.READ_WRITE);
	
	#Read all data from "save_file" and store
	#it into "save_data" (String) so that we
	#can index through it
	save_data = save_file.get_as_text();
	
	#NOTE: DEBUG
	if (fragment.blocks.is_empty() != true && debug == true):
		print("\n\nSave data is: ", save_data, "\n\n");
	
	#Find the begging of the fragment tag
	#From this data we will then find the begining of
	#the {, this will mark where we can begin removing data
	#from to wipe the fragment and can then rewrite the data
	#to the save file.
	fragmentDataStartIndex = save_data.find(fragTag);
	
	#NOTE: DEBUG
	if (fragment.blocks.is_empty() != true && debug == true):
		print("Found the fragTag at index: ", str(fragmentDataStartIndex, "  | It says: ", save_data.substr(fragmentDataStartIndex, 20)));
	
	#Find the position of the { bracket of the fragtag,
	#we can then run until we get to the } bracket, and will delete
	#everything between these two points for a fresh save of the
	#fragment
	#"fragmentDataStartIndex" will mark the beggining of "fragTag"
	#from this point we increase this index (file position) by
	#1 until we find the "{", we will then increment 1 more
	#time at ID: 89283923 to be right before the beggining of the
	#data set inside "{", this will be the start index where we can
	#safely write data without overriding anything important (like
	#fragtag, brackets marking where fragment save data is)
	while (save_data.substr(fragmentDataStartIndex, 1) != "{"):
		fragmentDataStartIndex += 1;
		pass;
	
	#ID: 89283923
	#Increment the index of the string to the right by 1
	#so that we go past "{" in the save file and are right at the begining
	#to where data should start for "fragment" in the save file
	fragmentDataStartIndex += 1;
	
	
	#Now we we need to determine the end index for the
	#"save_data" in the "fragTag". To determine the end 
	#index, we will use a while loop and just keep looping
	#until we find the "}" character, we will not need to increment'
	#one final time as in "ID: 89283923", because we are already
	#inside the data
	fragmentDataEndIndex = fragmentDataStartIndex; #Start where we know the data must begin, then we keep going forward till we find "}"
	while (save_data.substr(fragmentDataEndIndex, 1) != "}"):
		fragmentDataEndIndex += 1;
		pass;
	
	
	#Take all data related to "fragment" and remove all data in the "fragTag"
	#for it so that we can begin inserting new data.
	save_data = clearFragTag_SaveData(save_data, fragmentDataStartIndex, fragmentDataEndIndex);
	
	#NOTE: DEBUG
	if (fragment.blocks.is_empty() != true && debug == true):
		print("\n\nI cleared save data from the old fragTag, it now looks like: ", save_data, "\n\n");
	
	#Loop through each block, and write them
	#into "save_data" so it can be pushed into "save_file" later.
	for block in fragment.blocks:
		
		#Write block data for the current block in the format
		#(block.x, block.y, block.z, block.id). (Local corrdinates to the fragment)
		#This block data will then be stored in "save_data"
		blockData = "(" + str(block.position.x) + "," + str(block.position.y) + "," + str(block.position.z) + "," + str(block.block_id) + ")";
		
		#Write "blockData" to the save data. We start at the "fragmentDataStartIndex" and
		#once we wrote the data, we will increment the start index by the length of the
		#data so that we have a position to insert the next blocks data, using
		#fragmentDataStartIndex as a reference.
		save_data = save_data.insert(fragmentDataStartIndex, blockData);
		
		#increment the start index by the length of the
		#data so that we have a position to insert the next blocks data, using
		#fragmentDataStartIndex as a reference.
		fragmentDataStartIndex += blockData.length();
		
		pass;
	
	#NOTE: DEBUG
	if (fragment.blocks.is_empty() != true && debug == true):
		print("\n\nI wrote data to the save file! Here it is: ", save_data, "\n\nI am writing it to disk!");
	
	#Wipe "save_file" and rewrite "save_data" to it, so the new changes to the file
	#plus the old ones that are presently stored in "save_data"
	#will be written to the file
	#Then closes the file system.
	save_file.store_string(save_data);
	save_file.close();
	
	#NOTE: DEBUG
	if (fragment.blocks.is_empty() != true && debug == true):
		print("-------END FRAGMENT-------");
	
	pass;



func createSaveFile(fragment):
	
	#The area variables.
	#Derived from taking the global_position and getting
	#x or z respecitvely, dividing by 8 and flooring.
	#These represent the corrdinates of the save area the
	#the fragments are in.
	var area_x : int;
	var area_z : int;
	
	#The save path representing "C:\users\<USER>\AppData\Roaming\.gratisexemptus\Saves\<WorldName>\terrain"
	#Here is where the area save file will be stored in the terrain folder showing the worlds rendered
	#terrain.
	var save_path : String = default_world_save_path + world_save_name + world_save_terrain_folder;
	
	#The name of the save file (including extension ".gewd") to
	#be stored at path "save_path".
	var save_file_name : String;
	
	#Check to make sure the file doesn't already exist,
	#if it does exist, we will exit this function
	if (checkIfSaveFileExists(fragment) == true):
		return;
	
	
	#Determine the corrdinates of the save area
	#using int(floor(fragment.global_position.x / (global_variables.fragmentSideLength * global_variables.fragmentAreaSideLength)))
	area_x = int(floor(fragment.global_position.x / (global_variables.fragmentSideLength * global_variables.fragmentAreaSideLength)));
	area_z = int(floor(fragment.global_position.z / (global_variables.fragmentSideLength * global_variables.fragmentAreaSideLength)))
	
	#Get the save file name using the determined
	#area_x and area_z values plus the file extension
	save_file_name = str(area_x) + "." + str(area_z) + ".gewd";
	
	#Create the file by the name "save_file_name" for "fragment" in
	#the worlds terrain save folder
	FileAccess.open((save_path + "\\" + save_file_name), FileAccess.WRITE);
	
	pass;



#Goes to save file at "path" and creates a fragment
#tag inside it for "fragment"
func createFragmentTag(path, fragment):
	
	#Instance of the file at "path"
	#which we will insert the new fragment tag.
	var file : FileAccess;
	
	#The fragment tag we will insert
	#into the save file for "fragment"
	var fragmentTag : String;
	
	#The save data already in the file, so we can
	#insert the fragment tag as well as all
	#the data carrying said data over without
	#overwriting it.
	var save_data : String;
	
	#Open the file at "path", so we can insert a fragment
	#tag for this fragment "fragment".
	file = FileAccess.open(path, FileAccess.READ);
	
	#Store all existing data in a string "save_data"
	#so that we do not overwrite all existing
	#data in the file. When using "store_string()"
	#as part of FileAccess all data is overwritten
	#so by appending the fragment tag on "save_data"
	#we safely transfer over all data.
	save_data = file.get_as_text();
	
	#Switch file back to write mode so that we can override the files
	#data and insert the fragment tag and the old data "save_data"
	file = FileAccess.open(path, FileAccess.WRITE);
	
	#Built the fragment tag and store it in
	#"fragmentTag" using the global position of x and z
	#for the fragment "fragment" and other default formatting.
	fragmentTag = getFragmentTag(fragment, true);
	
	#Append the fragments tag to the end
	#of the save data, creating a tag for
	#the fragment to store data in when needed.
	save_data = save_data + fragmentTag;
	
	#Rewrite the save data back to the save file,
	#this time with the new fragment tag included
	file.store_string(save_data);
	
	pass;




#Returns the fragment tag of any
#fragment based on its global x and z
#corrdinates derived from argument "fragment"
#The fragment tag is returned as a String,
#
#----
#Arguments:
#
#fragment -> The fragment to get the fragment tag for
#
#inculdeBrackets -> If true, brackets "{}" will be included on the end
func getFragmentTag(fragment, includeBrackets : bool):
	#The fragment tag we will insert
	#into the save file for "fragment"
	var fragmentTag : String;
	
	#Built the fragment tag and store it in
	#"fragmentTag" using the global position of x and z
	#for the fragment "fragment" and other default formatting.
	fragmentTag = "<" + str(int(fragment.global_position.x)) + "," + str(int(fragment.global_position.z));
	
	#If "includeBrackets" is true, we will include the brackets
	#on the end of the tag "{}". This is important
	#for creating a new save file or rewriting data
	#in situations where we want the brackets included.
	if (includeBrackets == true):
		fragmentTag = fragmentTag + "{}";
	
	return fragmentTag;


#Takes "save_data" and a start and end index and will remove
#anything from in inbetween.
#Then returns the resaulting data, this is good for removing
#data from a fragment before writing save data to it.
#-----
#Arguments:
#
#save_data -> The save_data to manupulate and remove data from.
#
#fragmentDataStartIndex -> Start index of the fragTags data.
#
#fragmentDataEndIndex -> End index of the fragTags data.
func clearFragTag_SaveData(save_data, fragmentDataStartIndex, fragmentDataEndIndex):
	
	#Data to the operation for clearing save data from
	#a fragTag.
	var length_to_remove: int; #The total indexs of the save_data to remove.
	var part_before: String; #Part of the string before the removed section
	var part_after : String; #Part of the string after the removed section
	var result_string: String; #The resaulted string to return (part_before + part_after)
	
	# Calculate the length of the segment to remove
	length_to_remove = fragmentDataEndIndex - fragmentDataStartIndex
	
	# Get the part of the string before the unwanted segment
	part_before = save_data.left(fragmentDataStartIndex)
	
	# Get the part of the string after the unwanted segment
	# The starting index for the right part is where the removal ends
	part_after = save_data.right(save_data.length() - fragmentDataEndIndex)
	
	# Combine the two parts to form the new string
	result_string = part_before + part_after
	
	return result_string;



#Retrieves the value of a piece of meta data
#from the "meta" folder.
#Takes argument 1 "meta_tag" and searches
#\meta\meta.gemd for said meta_tag and
#returns the data associated with the meta tag.
#------
#ARGUMENTS:
#
#meta_tag -> The meta_tag to search \meta\meta.gemd for and if found, returns
#data associated with this tag.
func getMetaData(meta_tag : String):
	
	#The path to the meta data file
	#as part of the meta folder
	var path : String = default_world_save_path + world_save_name + world_save_meta_folder + "\\meta.gemd";
	
	#Instance of the file via FileAccess;
	#This is the world meta data file "meta.gemd"
	var meta_file : FileAccess;
	
	#The contents "meta_file" as text,
	#so we can parse through the data.
	var meta_data : String
	
	#The meta data retrieved from "meta_tag".
	#This is what we will return from this function.
	var meta_value;
	
	#The meta data start index. This marks
	#the begining of the meta data of the actual "meta_tag"
	#At this index, we can read until we hit "}", marking
	#the end of the meta data associated with "meta_tag"
	#This value will be computed later
	#------
	#metaDataEndIndex, is the last index of the meta
	#data associated with "meta_tag". This allows
	#us to pull all data between metaDataStartIndex
	#and metaDataEndIndex and this will be our
	#meta data.
	#-------
	#metaDataLength, is the length between start and end indexs of the
	#meta data. This will be used with substr() to pull
	#the meta data from said "meta_tag"
	var metaDataStartIndex : int = 0;
	var metaDataEndIndex : int;
	var metaDataLength : int;
	
	#Open the meta file and store instance of said
	#opened file in "meta_file" in READ mode,
	#so nothing is overrided and we can pull data
	#from it
	meta_file = FileAccess.open(path, FileAccess.READ);
	
	#Store the contents of the meta file
	#in "meta_data" so we can index through it.
	meta_data = meta_file.get_as_text();
	
	
	#Search through the meta data until we find
	#the "meta_tag". Once we found it we will increment
	#the metaDataStartIndex by "meta_tag" length + 1, so that
	#we don't include the meta tag or '{' in the final
	#value output for the meta tag
	while (meta_data.substr(metaDataStartIndex, meta_tag.length()) != meta_tag):
		metaDataStartIndex += 1;
		pass;
	metaDataStartIndex += meta_tag.length() + 1; #Add the length of "meta_tag" so that we skip it also increment one more time past "{", marking the start of the data associated with "meta_tag"
	
	
	#We know where the meta data associated with "meta_tag"
	#starts (metaDataStartIndex), we now simply
	#move along until we find "}" marking the datas end,
	#from here we can simply pull the data between
	#these two index (metaDataEndIndex, metaDataStartIndex) and
	#can get the meta data next.
	metaDataEndIndex = metaDataStartIndex; #Start where we know the data must begin, then we keep going forward till we find "}"
	while (meta_data.substr(metaDataEndIndex, 1) != "}"):
		metaDataEndIndex += 1;
		pass;
	
	
	#Figure out the total length of the meta data
	#and then use the length from the start index to
	#return the meta data associated with "meta_tag"
	#and store it in "meta_value" so we can
	#return our meta data.
	metaDataLength = metaDataEndIndex - metaDataStartIndex;
	meta_value = meta_data.substr(metaDataStartIndex, metaDataLength);
	
	#Return the meta_value associated with "meta_tag",
	#from the \meta\meta.gemd
	return meta_value;



#Creates a new world for the
#player to load into.
#Called from MainMenu.
#----------
#Default meta data will be created:
#world_name, terrain_seed, biome_seed
#----------
#Default paths/folders will be created:
#\meta -> For meta data saves; Player meta-data, world meta-data
#\terrain -> For blocks, walls and terrain save info; Changes to the world and terrain are saved here
#----------
#ARGUMENTS:
#
#worldName -> The name the world will be saved under
#
#seed -> The seed to generate noise for the terrain, biomes, and everything in the world
func createNewWorld(worldName : String, seed : int):
	
	#The meta file, which we will
	#store world meta data in.
	#We also intially create the file
	#off this instance as well.
	var metaFile : FileAccess;
	
	#Take the "worldName" argument and create
	#the world save folder in the "Saves" folder
	#in ".gratisexemptus"; Then create
	#all default directories such as
	#"\terrain", "\meta", etc
	DirAccess.make_dir_absolute(default_world_save_path + "\\" + worldName);
	DirAccess.make_dir_absolute(default_world_save_path + "\\" + worldName + "\\meta"); #Meta data directory
	DirAccess.make_dir_absolute(default_world_save_path + "\\" + worldName + "\\terrain"); #Terrain data directory
	DirAccess.make_dir_absolute(default_world_save_path + "\\" + worldName + "\\player") #Player data directory
	
	#Set the current world name so we can
	#access it in different WorldSaveSystem utilities
	#later when writing save data
	world_save_name = "\\" + worldName;
	
	#Create and set all meta-tags insde
	#"\meta\meta.gemd" so we have all
	#meta data for the world stored
	#in the save
	metaFile = FileAccess.open(default_world_save_path + world_save_name + "\\meta\\meta.gemd", FileAccess.WRITE);
	
	#Write all default world meta
	#data to the metaFile.
	var data : String = "(world_name{" + worldName + "})(seed{" + str(seed) + "})";
	metaFile.store_string(data);
	
	#Create save files and utilities for
	#saving the backpack (inventory)
	#of the player.
	createInventorySaveFile();
	
	
	#Everything is created, the world has been created as
	#a save in "Saves" in ".gratisexemptus" folder
	pass;


#Takes the "items[]" array from the player
#as an argument and writes it to the
#default player inventory save file
#"backpack.gepd".
#FORMAT:
#    If Item:  index, block_id, stack_height
#    If null: index, "null"
func saveInventory(backpack) -> void:
	
	#The String we will write all save data to.
	#Once we write this string, we will write it
	#to "backpack.gepd" to save all data from
	#the players backpack.
	var save_data : String = "";
	
	#The index we are looping through while writing
	#save data to "backpack.gepd" for "<backpack_indexes".
	#at ID: 32890482843023840.
	var index : int = 0;
	
	#Open the inventory save file in write mode,
	#so we can write the contents of "backpack" to it.
	inventory_save_file = FileAccess.open(default_world_save_path + world_save_name + "\\player\\backpack.gepd", FileAccess.WRITE);
	
	#ID: 32890482843023840
	#Loop through and write
	#all player inventory items/data
	#to "save_data" string, which is then
	#going to be written to "backpack.gepd"
	#which is the save data file for the
	#players inventory.
	for item in backpack:
		
		#If we are at a null index of the
		#backpack, then write null to the
		#indexes space in the save, then continue
		#to the next iteration of this loop
		if (backpack[index] == null):
			save_data = save_data + "(INDEX:" + str(index) + "),";
			index = index + 1;
			continue;
		
		#Write
		save_data = save_data + "(INDEX:" + str(index) + "," + str(item.block_id) + "," + str(item.stack_height) + "),";
		
		#Increment the index
		#we are currently on for the
		#"backpack[]" array of the player
		#save data
		index = index + 1;
		
		pass;
	
	#Write all data from "save_data"
	#(all the save data from the players inventory)
	#to the save data file "backpack.gepd"
	inventory_save_file.store_string(save_data);
	
	pass;


#Returns the last saved index of the inventory
#at the index of "index" for the inventory.
#----------
#ARGUMENTS:
#index -> the index to return for the inventory.
func loadInventory(index : int):
	
	#The return status of this function.
	#Each time we call "feedInventory"
	#we will feed the next index of the backpack
	#back to the point at which this funcition
	#is called.
	var item = null;
	
	#The save data from "inventory_save_file"
	#(the save data for the inventory)
	var save_data : String;
	
	#Take the "inventory_save_file" located at
	#"\\player\\backpack.gepd" and open it
	inventory_save_file = FileAccess.open(default_world_save_path + world_save_name + "\\player\\backpack.gepd", FileAccess.READ);
	
	#Store the save data from the
	#backpack save file to the "save_data"
	#variable as a string so we can index
	#through the data.
	save_data = inventory_save_file.get_as_text();
	
	#If the save_data is empty (no save data),
	#we will just automatically return null,
	#since the inventory is completely empty.
	if (save_data == ""):
		return null;
	
	#Determine where the index is in the save file.
	#We will create a string with the "INDEX:" tag
	#and the index location and will search for the indexes
	#location
	var indexTag : String = "INDEX:" + str(index);
	#Get the position for the "INDEX:", this will be
	#the position of the indexes save.
	#From this position we keep indexing and can get
	#"block_id" (item, what it is) and the stack_height (how
	#much of the item we had).
	var save_data_position : int = save_data.find(indexTag) + indexTag.length();
	
	#This point represents what piece of
	#data we are actively pulling from
	#the inventory save file format.
	#0 = block_id
	#1 = stack_height
	#2 = exit loop
	var data_point : int = 0;
	
	while (data_point != 2):
		#We will run from the coma's position
		#until the next coma or ), which we will
		#then pull the data from between these
		#characters and depending on the index
		#we are on, our data type will be saved.
		while (save_data.substr(save_data_position, 1) != "," && save_data.substr(save_data_position, 1) != ")"):
			save_data_position = save_data_position + 1;
			pass;
		
		#If we get ")", then there is not data for this
		#index as this index had nothing in it in the backpack.
		if (save_data.substr(save_data_position, 1) == ")" && data_point == 0):
			item = null;
			return item;
		#Here we have a variable storing the start position
		#of the data type we are pullling for the "index" of the inventory.
		#We will use this, in company with "save_data_position"
		#later to find the block_id.
		var data_index : int = save_data_position + 1;
		save_data_position = save_data_position + 1;
		
		#We will increment "save_data_position"
		#until we hit the next ",", and will then
		#find the value between "save_data_position"
		#and "data_index", and this will be our
		#data type
		while (save_data.substr(save_data_position, 1) != "," && save_data.substr(save_data_position, 1) != ")"):
			save_data_position = save_data_position + 1;
		
		#If we are on data_point 0 (block_id),
		#We will instantitate the block
		#type from the block table using the data from data_point 0.
		if (data_point == 0):
			item = global_variables.block_table[int(save_data.substr(data_index, save_data_position - data_index))].instantiate();
			pass;
		
		#If we are on data_point 1 (stack_height),
		#we will set the stack height as the data.
		if (data_point == 1):
			item.stack_height = int(save_data.substr(data_index, save_data_position - data_index));
			pass;
		
		#Increment the data point we are on.
		#This point represents what piece of
		#data we are actively pulling from
		#the inventory save file format.
		data_point = data_point + 1;
		
	
	
	#Return the item we created from the
	#"index" of the backpack from the "backpack.gepd"
	#file.
	return item;


#Creates an inventory save file
#for the players backpack to be saved
#to. (.gepd)
func createInventorySaveFile() -> void:
	
	#Take the "inventory_save_file" located at
	#"\\player\\backpack.gepd" and open/create
	#it. We will then write the default
	#save formatting in it next.
	inventory_save_file = FileAccess.open(default_world_save_path + world_save_name + "\\player\\backpack.gepd", FileAccess.WRITE);
	
	pass;



#When called,
#this function makes sure "\\AppData\\Roaming\\.gratisexemptus\\Saves"
#exists, so that world saves can be created and stored
#without issue.
func ensureDefaultSaveDirExists():
	
	#If the "default_world_save_path" path "\\.gratisexmeptus\\Saves"
	#folder/path does not exist, then create its
	#directory so world saves have a place to be
	#stored, as well as meta data for the game.
	if (DirAccess.dir_exists_absolute(default_world_save_path) == false):
		DirAccess.make_dir_recursive_absolute(default_world_save_path);
	
	pass;


#Takes a position "pos" (Vector3) and a rotation (float) and saves
#it to the "\player\spawn.gepd" file so we can
#load the players previous position in from
#where they saved.
#-------------
#ARGUMENTS:
#pos -> The players position during save.
#rot -> players rotation during save.
func saveSpawn(pos : Vector3, rot : float) -> void:
	
	#Open the spawn save file in
	#"spawn_save_file" so we can write
	#the players last location to it while
	#saving
	var spawn_save_file = FileAccess.open(default_world_save_path + world_save_name + "\\player\\spawn.gepd", FileAccess.WRITE);
	
	#This will contain the save_data
	#we are going to write to the spawn save file
	#"spawn_save_file".
	var save_data : String = "";
	
	#Create the spawn save data and write it to
	#"save_data", so we can write the data
	#of where the player last was to the
	#spawn save file
	save_data = "(" + str(pos.x) + "," + str(pos.y) + "," + str(pos.z) + "," + str(rot) + ")";
	
	#Write the spawn location to the spawn
	#save file, we will then load this position
	#later.
	spawn_save_file.store_string(save_data);
	
	pass;


#Retrieves the players spawn from the save file
#"spawn.gepd". Returns a Vector4, which
#is the players position plus rotation.
func loadSpawn():
	
	#The players position loaded from save.
	#This will be the (x, y, z) + w (rotation)
	var position : Vector4 = Vector4(0, 0, 0, 0);
	
	#Open the spawn save file in
	#"spawn_save_file" so we can read
	#the players last location from saves
	var spawn_save_file = FileAccess.open(default_world_save_path + world_save_name + "\\player\\spawn.gepd", FileAccess.READ);
	
	#If the file doesn't exist for the players spawn,
	#then we will return null, since now spawn
	#position was ever saved.
	if (spawn_save_file == null):
		return null;
	
	#This will contain the save_data
	#from spawn save file
	var save_data : String = spawn_save_file.get_as_text();
	
	#If the save_data doesn't exist for the
	#players spawn point, then return null.
	if (save_data == ""):
		return null;
	
	#This point represents what piece of
	#data we are actively pulling from
	#the inventory save file format.
	#0 = block_id
	#1 = stack_height
	#2 = exit loop
	var data_point : int = 0;
	
	var save_data_position : int = 0;
	
	while (data_point != 4):
		#We will run from the coma's position
		#until the next coma or ), which we will
		#then pull the data from between these
		#characters and depending on the index
		#we are on, our data type will be saved.
		while (save_data.substr(save_data_position, 1) != "," && save_data.substr(save_data_position, 1) != ")" && save_data.substr(save_data_position, 1) != "("):
			save_data_position = save_data_position + 1;
			pass;
		
		#Here we have a variable storing the start position
		#of the data type we are pullling for the "index" of the inventory.
		#We will use this, in company with "save_data_position"
		#later to find the block_id.
		var data_index : int = save_data_position + 1;
		save_data_position = save_data_position + 1;
		
		#We will increment "save_data_position"
		#until we hit the next ",", and will then
		#find the value between "save_data_position"
		#and "data_index", and this will be our
		#data type
		while (save_data.substr(save_data_position, 1) != "," && save_data.substr(save_data_position, 1) != ")"):
			save_data_position = save_data_position + 1;
		
		#If we are on data_point 0 get
		#the x position.
		if (data_point == 0):
			position.x = int(save_data.substr(data_index, save_data_position - data_index));
			pass;
		
		#If we are on data_point 1 get
		#the y position.
		if (data_point == 1):
			position.y = int(save_data.substr(data_index, save_data_position - data_index));
			pass;
		
		#If we are on data_point 2 get
		#the z position.
		if (data_point == 2):
			position.z = int(save_data.substr(data_index, save_data_position - data_index));
			pass;
		
		#If we are on data_point 3 get
		#the w position.
		if (data_point == 3):
			position.w = int(save_data.substr(data_index, save_data_position - data_index));
			pass;
		
		#Increment the data point we are on.
		#This point represents what piece of
		#data we are actively pulling from
		#the inventory save file format.
		data_point = data_point + 1;
	
	
	return position;
