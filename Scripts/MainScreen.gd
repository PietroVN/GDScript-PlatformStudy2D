extends Control

func _on_Play_pressed():# If play button is pressed
	get_node("/root/Main").scene = load("res://Scenes/World.tscn").instance();  # load and instance World scene
	queue_free();
	
func _on_Exit_pressed(): # If exit pressed
	get_tree().quit() # Close game
