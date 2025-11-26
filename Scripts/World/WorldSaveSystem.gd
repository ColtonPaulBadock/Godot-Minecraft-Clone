#This script manages and interprets all world saves
#It contain utilities to read, save and index
#any world save file.

extends Node

#The save name (this will be the worlds name)
var world_save_name : String = "\\FirstWorldSave";

#Stores the users username and path,
#EXAMPLE: "C:\users\<USERNAME>\
var user_path : String = OS.get_environment("USERPROFILE");

#The default world save path.
#Which points to the ".gratisexemptus" folder and the
#"Saves" folder inside it.
var default_world_save_path : String = "\\AppData\\Roaming\\.gratisexemptus\\Saves";

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
	path = user_path + default_world_save_path + world_save_name + world_save_terrain_folder + "\\" + str(x_area) + "." + str(z_area) + ".gewd";
	
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
	
	
	print(save_data);
	
	
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
	
	#Open the file at "path", so we can insert a fragment
	#tag for this fragment "fragment".
	file = FileAccess.open(path, FileAccess.WRITE_READ);
	
	while (file == null):
		pass;
	
	
	#Runs to the end of the file
	#So we can insert a new line and add a fragment
	#tag for fragment "fragment"
	file.seek_end(0);
	
	#Place a newline,
	#so we can insert a new fragment tag
	file.store_string("\n");
	
	#Built the fragment tag and store it in
	#"fragmentTag" using the global position of x and z
	#for the fragment "fragment" and other default formatting.
	fragmentTag = getFragmentTag(fragment);
	
	file.store_string(fragmentTag);
	
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
