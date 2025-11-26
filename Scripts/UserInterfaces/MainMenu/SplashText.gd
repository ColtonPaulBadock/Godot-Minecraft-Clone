#This class/script runs the "SplashText" node
#inside the MainMenu scene.
#Here the splash text is intialized, and is set to
#pulsate.

extends RichTextLabel

#The current splash text
#Will be shown on the main menu
var splashText : String;

#All current splash texts in the game
var splashTexts = ["George still hasn't been found!",
"FACT: Longest splash text in game!",
"Sic Semper Tyranus!",
"The Kingdoms Coming!",
"Steiners attack was an order!",
"All Hail King Terry!",
"Console.WriteLine(\"2021!\");",
"Check and Sum…",
"This ain't Joever yet...",
"Don’t be a salty muffin!",
"Oh, so how the muffin crumbles…",
"Shes the yellow rose of texas!",
"Made in Cascadia!",
"Made in Washington!",
"Made in Arlington!",
"Godot 4.5!",
"NEED... MORE... RAM...!",
"Also Try Minecraft",
"Also Try Terraria",
"Number Stations Included!",
"27.025 MHz!",
"Have fun, Good Buddy!",
"Woah!",
"Déjà vu!",
"Hello, World!",
"Ride I-5!",
"Mind... BLOWN!",
"Bugs included, no charge!",
"ColtonPaulBadock.com",
"GratisExemptus.com",
"Notch wasn't here...",
"As seen on TV!",
"Leave reviews on channel 19!",
"smackthecreepr2@proton.me"];



#Info used to make the splash text flash/pulsate
var splashText_fontSize = 27;
var splashText_maxFontSize : int = 30; #The max size the font can be while flashing
var splashText_minFontSize : int = 25; #The min size the font can be while flashing
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
	if (splashText_timeSinceFontSizeChange > 0.06):
		
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
		
		#Reset the time since the font changed,
		#as we just changed it.
		splashText_timeSinceFontSizeChange = 0.0;
	
	#Set the font size to the current size "splashText_fontSize",
	#so that the animation of the splash text flashing/pulsating can
	#be seen
	add_theme_font_size_override("normal_font_size", splashText_fontSize)
	
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
