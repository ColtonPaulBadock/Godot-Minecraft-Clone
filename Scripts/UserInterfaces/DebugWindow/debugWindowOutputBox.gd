extends RichTextLabel


#Clears the logs and all text from the Output Box
func clearLogs() -> void:
	
	#Clear the rich text label, as simple as that!?
	clear(); 
	
	pass;


#Writes the 1st argument (String) to the OutputBox
#Basically the same as say "print()" or "System.out.print()" but
#it outputs to the OutputBox in the Debug/Terminal window
func writeLog(message : String) -> void:
	
	#Write the message to the OutputBox
	add_text(message);
	
	pass;
