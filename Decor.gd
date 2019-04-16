extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (Array, Image) var images := []

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	init()
	pass # Replace with function body.


func init():
	$Sprite.texture = images[rand_range(0, images.size())]
	position.x = get_viewport().get_size().x + $Sprite.texture.get_size().x
	position.y = 0.0
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_VisibilityNotifier2D_screen_exited():
	pass # Replace with function body.


func _on_Timer_timeout():
	print("Time out")
	init()
	pass # Replace with function body.


func _on_VisibilityNotifier2D_viewport_exited(viewport):
	print("Exited")
	print(position)
	$Timer.start()
	pass # Replace with function body.
