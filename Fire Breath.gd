extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var reset_position := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	if(reset_position):
		var parent = get_parent()
		var target = $"../Dragon/Body/Jaw".get_relative_transform_to_parent(parent).origin
		var xform = get_transform()
		parent.remove_child(self)
		xform.origin = target
		set_transform(xform)
		parent.add_child(self)
		#get_node("/root/Game").add_child(self)
		reset_position = false
		
	self.move_and_collide(Vector2(-10.0, 0.0))

func reset():
	reset_position = true

func _on_Area2D_body_entered(body):
	var player = body.find_parent("Player")
	if(player):
		player.get_node("Torso").decrement_health(5.0)
		self.position.y += 1000.0
