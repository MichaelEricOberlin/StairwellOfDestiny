extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var orig_xform

# Called when the node enters the scene tree for the first time.
func _ready():
	orig_xform = self.get_transform()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#self.rotation = lerp(self.rotation, xform.get_rotation(), 1.0)
	#pass

#func _integrate_forces(physics_state):
	#set_applied_force(thrust.rotated(-PI/2.0).rotated(rotation))
	#set_applied_torque(spin_power * rotation_dir)
	if($"../Torso".correct_angles):
		self.rotation = lerp(self.rotation, orig_xform.get_rotation(), 0.8)
	"""var xform = physics_state.get_transform()
	
	xform = xform.rotated(lerp(0, orig_xform.get_rotation() - xform.get_rotation(), 1.0))
	physics_state.set_transform(xform)"""

