#This class/script runs the "SplashText" node
#inside the MainMenu scene.
#Here the splash text is intialized, and is set to
#pulsate.

extends RichTextLabel

#The current splash text
#Will be shown on the main menu
var splashText : String;

#All current splash texts in the game
var splashTexts = ["<LOREM IPSUM, DOLLER SIT AMIT. TEST>"];



#Info used to make the splash text flash/pulsate
var splashText_fontSize = 45;
var splashText_maxFontSize : int = 50; #The max size the font can be while flashing
var splashText_minFontSize : int = 20; #The min size the font can be while flashing
var splashText_timeSinceFontSizeChange = 0; #Time elapsed in milliseconds since the font size changed.
var splashText_growingInSize : bool = false; #If true, the splash text is growing in size, if false, its shrinking


#Runs once when the MainMenu starts.
func _ready() -> void:
	
	#Sets the splash text to a random
	#text from the "splashTexts[]" array.
	setSplashText();
	
	pass;


#Runs infinetly until the MainMenu closes
func _process(delta: float) -> void:
	
	#Flash the splash text on the main menu.
	#This makes it pulsate in size to appear like its flashing.
	flashSplashText(delta);
	
	pass;



#Makes the splash text grow and shrink to appear as if its flashing
#Takes the time elapsed since the last frame as a argument.
#--------
#Arguments:
#
#timeElapsed = milliseconds since the last frame, used to determine when to flash the text
func flashSplashText(timeElapsed) -> void:
	
	#Update the total time that has passed since the splash text changed.
	splashText_timeSinceFontSizeChange = splashText_timeSinceFontSizeChange + timeElapsed;
	
	#If its been 50 milliseconds or more since the font grew or shrunk
	#in size, then we can move on and shrink or grow the size of the
	#splash text to give it the effect the splash text is flashing
	#according to if "splashText_growingInSize" is true or false.
	if (splashText_timeSinceFontSizeChange > 50):
		
		#If the splash text is growing in size, then make
		#it bigger to appear as though it is flashing.
		if (splashText_growingInSize == true):
			
			#Increase the font size of the splash text by 1 font size.
			splashText_fontSize = splashText_fontSize + 1;
			
			#If we have reached the max font size, we can set
			#"splashText_growingInSize" variable to false, to make
			#the splash text begin shrinking.
			if (splashText_fontSize == splashText_maxFontSize):
				splashText_growingInSize = false;
		
		if (splashText_growingInSize == false):
			#Decrease the font size of the splash text by 1 font size.
			splashText_fontSize = splashText_fontSize - 1;
			
			#If we have reached the min font size, we can set
			#"splashText_growingInSize" variable to try, to make
			#the splash text begin growing.
			if (splashText_fontSize == splashText_minFontSize):
				splashText_growingInSize = true;
	
	#Set the font size to the current size "splashText_fontSize",
	#so that the animation of the splash text flashing/pulsating can
	#be seen
	normal_font_size = splashText_fontSize;
	
	pass;


func setSplashText() -> void:
	
	#Set a random splash text from
	#"splashTexts[]" as the splash text to be displayed.
	splashText = getSplashText();
	
	#Clear the current "SplashText" text from the node.
	#This is so we can append a new text without the old text
	#being on the front of the string.
	clear();
	
	#add the splash text to the "SplashText" node as text.
	#This will show the splash text on the main menu.
	add_text(splashText);
	
	pass;


#Returns a random splash text from "splashTexts[]" array.
func getSplashText() -> String:
	#Return a random position for the "splashText[]" array.
	#Between 0 and the size of the array using "randi_range()"
	#Subtract 1 from the final rng output, to factor in 0 being a valid index
	return splashTexts[(randi_range(0, splashTexts.size()) - 1)];
