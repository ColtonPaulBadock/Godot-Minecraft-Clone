extends Control

#Instance of corrdinate display text box, holding corrdinates on the right of the debug window.
@onready var corrdinateDisplay = get_node("DebugWindowPanel/CorrdinateDisplay");

#Instance of the "InputBox" node;
#This node gives the player a UI to write commands into, send messages, etc
@onready var inputBox = get_node("DebugWindowPanel/InputBox");

#Instance of "OutputBox" which the terminal/debug window will output to.
@onready var outputBox = get_node("DebugWindowPanel/OutputBoxPanel/OutputBox");

#Instance of the world
@onready var world = get_tree().get_root().get_node("World");

#Challenges in the world
var degradeWorldChallenge = preload("res://Scenes/Challenges/DegradeWorldChallenge.tscn"); #This challenge degrades the world away

#Random number generator utility
var rng = RandomNumberGenerator.new();

func _ready() -> void:
	
	pass;


func _process(delta):
	
	controlDebugWindow(); #Updates the debug window with new debug data, allows for commands, etc.
	
	pass;


#Shows/opens the debug window to the user
#Intialises componenets and systems in the debug window.
func initDebugWindow() -> void:
	
	#DEVLOG
	print("Opened debug window|debugWindow.gd, initDebugWindow()");
	
	#Disables scrolling of the corrdinate display, so the scroll bar does not show up.
	corrdinateDisplay.scroll_active = false;
	
	#Make the debug window visible
	visible = true;
	
	#Free the mouse and disble all inputs in the game so that
	#the debug window can be interacted with/used
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE); #Unbound the mouse and take out camera movement.
	global_variables.inputAllowed = false; #Disable all player input for the debug window being open
	
	pass;


#Closes/terminates not needed systems in the debug window and closes the debug window.
func killDebugWindow() -> void:
	
	#DEVLOG
	print("Killed debug window|debugWindow.gd, killDebugWindow()");
	
	#Hide the debug window
	visible = false;
	
	#Set the mouse back to its original state, so it is captured and hidden
	#in the window for gameplay.
	#Also enable player input again
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN);
	global_variables.inputAllowed = true; #Enables player input.
	
	pass;


#Controls all aspects in the debug window
func controlDebugWindow() -> void:
	
	#Listen for input to open/close the debug window.
	#Deactivates game input if the debug window is open
	listenForDebug_openAndClose();
	
	#Updates the corrdinates displayed in the debug window.
	updateCorrdinates_DebugWindow();
	
	#Controls and manages the input box for commands.
	manageInputBox();
	
	pass;


#Manages the "InputBox" node;
#Keeps the terminal path and prevents the user from deleting it, accepts inputs, etc
func manageInputBox() -> void:
	
	#If the debug window is not open, then don't manage
	#the input box, it shouldn't be useable
	if (global_variables.debugWindowOpen == false):
		return;
	
	
	#If any key mapped to "debugTerminal_submit", then get the text in "InputBox"
	#Evaluate this text for commands, if no commands,
	#then we need to send it as a message.
	if (Input.is_action_just_pressed("debugTerminal_submit")):
		
		#Take the text inside the input box and pass it to
		#the command evaluator "evaluateCommands()"
		#Once the command is sent out, clear "inputBox" for the next command, message
		#etc
		evaluateCommands(inputBox.text);
		inputBox.clear(); #Clear "inputBox" of all text.
		
		pass;
	
	pass;


#Takes in a String as the first argument, then evlautes it for commands
#If no command notation is found, then the String is posted as a message
#This is the main command function
#MAIN COMMAND FUNCTION
#-Commands List-
#-marco -> Prints the world "Polo!" back to the user.
#-clear -> Clears the "OutputBox" of any logs
#-Phoebe -> ?!?!?!?! This isn't a command
#-challenge DEGRADE_WORLD -> Starts the degrade world challenge, where blocks slowly disapear
func evaluateCommands(message : String) -> void:
	
	#DEVLOG
	print("Evaluateing commands|debugWindow.gd, evaluateCommands()");
	
	#"-marco" command, prints "Polo!" in "OutputBox"
	if (message.begins_with("-marco")):
		outputBox.writeLog("Polo!\n");
		return;
	
	#"-clear" command, clears the "OutputBox" of all logs
	if (message.begins_with("-clear")):
		outputBox.clear();
		return;
	
	#"-Phoebe"; What the hell even is that?
	if (message.begins_with("-Phoebe")):
		var rngNum = rng.randi_range(0, 10); #Generate a random number between 0-10 to print a random song lyric
		if (rngNum < 5):
			outputBox.writeLog("And thats the trouble with a HEARTBREAK\nIts gonna hang around\nLeave you midnight breakin' down\nWonderin' how\nLong its gonna take\nGettin' over her\n");
		elif (rngNum >= rngNum):
			outputBox.writeLog("You're one of them girls that\nAin't handin' out your number\nYou like to make us want you\nYou like to make us wonder!\n");
		
		return;
	
	
	#"-challenge DEGRADE_WORLD"; Starts the worlds degrades challenge, which slowly destroys the world.
	if (message.begins_with("-challenge DEGRADE_WORLD")):
		
		#Temporary load the degradeWorldChallenge scene into "tempScene"
		#and instanitate it, then add it to the world node, so the
		#degrading challenge can start!
		var tempScene = degradeWorldChallenge.instantiate();
		world.add_child(tempScene);
		
		return;
	
	
	#If no commands were found, send the text as a message;
	#The leave this function
	outputBox.writeLog(global_variables.username + "> " + message + "\n");
	
	pass;

#Listens for the keys binded to "open_debug_window";
#If these keys are pressed, disable input into the game ane allow the user to use the debug window.
#Once "open_debug_window" keys are pressed again, close the debug window and allow game input again.
func listenForDebug_openAndClose():
	
	#If keybinds to open the debug window have been pressed,
	#allow the user to interact with the debug window or close it,
	#depending on wether global variable "debugWindowOpen" is truefalse
	if (Input.is_action_just_pressed("open_debug_window")):
		global_variables.debugWindowOpen = !global_variables.debugWindowOpen;
		
		#If the debug window is being opened, intialize the componenets inside it before displaying
		#it to the user.
		if global_variables.debugWindowOpen == true:
			initDebugWindow();
			pass;
		
		#If the debug window is being closed, kill the debug window and remove uneeded
		#components inside it.
		if global_variables.debugWindowOpen == false:
			killDebugWindow();
			pass;
		pass;
	pass;


#Updates the corrdinates displayed in the debug window.
func updateCorrdinates_DebugWindow() -> void:
	
	#Holds instance of the player corrdinates from the main scene tree.
	var player = get_tree().get_root().get_node("World/Player").position;
	
	corrdinateDisplay.clear(); #Clear the corrdinate box for the updated corrdinates from this frame
	#Using method floatToString_removeDecimalPlaces() to remove excess decimals off the corrdinates
	corrdinateDisplay.add_text("CORRDINATES: \nX:" + floatToString_removeDecimalPlaces(player.x, 3) + "\nY: " + floatToString_removeDecimalPlaces(player.y, 3) + "\nZ: " + floatToString_removeDecimalPlaces(player.z, 3)); #Add the current corrdinates in this frame to display
	
	pass;

#Function removes excess decimal places off floats, converts them to a string.
#workingNumber = the number to remove the excess float from
#placesToKeep = places after the decimal point to keep.
func floatToString_removeDecimalPlaces(workingNumber, placesToKeep) -> String:
	
	#This variable holds the float we want to remove the excess decimal places from
	#It is being converted to a string here.
	#ID: 672gsdg
	var float_stringFormatted : String = str(workingNumber);
	var decimalCharPosition; #Holds the array string index of the character "." in String "float_stringFormatted"
	
	#Locate the index of "." in the String (which was a float, we convereted to string at ID: 672gsdg).
	#This index will be used to then delete unwanted decimals at ID: 7ehdgfat.
	decimalCharPosition = float_stringFormatted.find(".");
	
	#ID: 7ehdgfat
	#Go to decimal position in the string, then go "placesToKeep" to the right and delete the rest of
	#the unwanted decimal
	float_stringFormatted = float_stringFormatted.erase(decimalCharPosition + placesToKeep, 15);
	
	#Return the finished string since we removed access decimals and formated the float.
	return float_stringFormatted;
