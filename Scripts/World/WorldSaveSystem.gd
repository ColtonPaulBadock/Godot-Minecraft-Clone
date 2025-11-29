#This script manages and interprets all world saves
#It contain utilities to read, save and index
#any world save file.

extends Node

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
var world_save_terrain_folder : String = "\\terrain";

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
	path = user_path + default_world_save_path + world_save_name + world_save_terrain_folder + "\\" + str(x_area) + "." + str(z_area) + ".gewd";
	
	
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
	
	
	#We know the file exists, and we know it has
	#a fragment tag at this point.
	#We now want to locate the tag, and
	#override everything in {} with the new save data
	#for the fragment
	fragTag = getFragmentTag(fragment);
	
	#Open the save file, this will be so we
	#can extract all data from it, and
	#write all data back to it once we are
	#done manipulating it.
	save_file = FileAccess.open(path, FileAccess.READ_WRITE);
	
	#Read all data from "save_file" and store
	#it into "save_data" (String) so that we
	#can index through it
	save_data = save_file.get_as_text();
	
	
	#Find the begging of the fragment tag
	#From this data we will then find the begining of
	#the {, this will mark where we can begin removing data
	#from to wipe the fragment and can then rewrite the data
	#to the save file.
	fragmentDataStartIndex = save_data.find(fragTag);
	
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
	
	
	#Wipe "save_file" and rewrite "save_data" to it, so the new changes to the file
	#plus the old ones that are presently stored in "save_data"
	#will be written to the file
	#Then closes the file system.
	save_file.store_string(save_data);
	save_file.close();
	
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
	var save_path : String = user_path + default_world_save_path + world_save_name + world_save_terrain_folder;
	
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
	fragmentTag = getFragmentTag(fragment);
	
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
func getFragmentTag(fragment):
	#The fragment tag we will insert
	#into the save file for "fragment"
	var fragmentTag : String;
	
	#Built the fragment tag and store it in
	#"fragmentTag" using the global position of x and z
	#for the fragment "fragment" and other default formatting.
	fragmentTag = "<" + str(int(fragment.global_position.x)) + "," + str(int(fragment.global_position.z)) + "{}";
	
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
