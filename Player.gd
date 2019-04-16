extends RigidBody2D

export (float) var acceleration = 10.0
export (Array, AudioStream) var crashes := []

var impulse_dir := 0
onready var root = $"/root/Game";
var orig_xform
var correct_angles := false
var live := true

export (float) var health := 100.0

export (Array, AudioStream) var shouts := []

# Called when the node enters the scene tree for the first time.
func _ready():
	orig_xform = self.get_transform()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#warning-ignore:unused_argument
func _process(delta):
	if(Input.is_action_pressed("Restart")):
		get_tree().reload_current_scene()
	
	if($"/root/Game/Stairwell".rolling):
		if(live):
			impulse_dir = 0
			if(Input.is_action_pressed("go_left")):
				impulse_dir -= 1
			if(Input.is_action_pressed("go_right")):
				impulse_dir += 1
			if(Input.is_action_pressed("more_bounce")):
				#Consider adding "bounciness" factor, and using it to lerp both bounce and mass
				#Then, add upward force when contacting ground
				#(Maybe alter gravity_scale for all kindred?)
				correct_angles = true
				#self.physics_material_override.bounce += 5 * delta
				
				var space_state = get_world_2d().direct_space_state
		    	# use global coordinates, not local to node
				var result = space_state.intersect_ray(Vector2(0, 0), Vector2(0, -100))
				if(result.collider != null):
					self.linear_velocity += Vector2(0.0, -10.0)
					#self.add_force(Vector2(), Vector2(0.0, 1000.0))
			else:
				correct_angles = false
	else:
		if(Input.is_action_pressed("go_right")):
			var cat = $"/root/Game/Stairwell/Whiskers MacKillface"
			var audio = cat.get_node("AudioStreamPlayer2D")
			audio.stream = cat.meows[rand_range(0, cat.meows.size())]
			audio.play()
			$"/root/Game/Stairwell".rolling = true
			$"../Shouting/Timer".start()
			for body in kindred_bodies():
				body.mode = RigidBody2D.MODE_RIGID
			self.mode = RigidBody2D.MODE_RIGID
		
	pass

func _physics_process(delta):
	if($"/root/Game/Stairwell".rolling):
		self.linear_velocity.x += delta * impulse_dir * acceleration
	
	#Correct Torso Angle
	var new_angle = ($"../Helmet".get_relative_transform_to_parent(root).origin - \
		($"../Leg_R".get_relative_transform_to_parent(root).origin + $"../Leg_R".get_relative_transform_to_parent(root).origin)/2.0)\
		.angle()
	self.rotation = new_angle
	
	
func kindred_bodies():
	return [$"../Leg_L", $"../Leg_R", $"../Arm_L", $"../Arm_R", $"../Helmet", $"../Sword"]

#warning-ignore:unused_argument
func _integrate_forces(physics_state):
	#set_applied_force(thrust.rotated(-PI/2.0).rotated(rotation))
	#set_applied_torque(spin_power * rotation_dir)
	if(correct_angles):
		self.rotation = lerp(self.rotation, orig_xform.get_rotation(), 1.0)

func decrement_health(dec):
	health -= dec
	
	$"/root/Game/ColorRect/Knight Health".rect_size.x = (health / 100.0) * 200
	
	if(health <= 0.0 and $"/root/Game/Dragon".live):
		explode()

func explode():
	if(live):
		live = false
		for body in kindred_bodies():
			body.get_node("Joint").queue_free()
		correct_angles = false
		$"/root/Game/Defeat".show()

func random_crash():
	$AudioStreamPlayer2D.stream = crashes[rand_range(0, crashes.size())]
	$AudioStreamPlayer2D.play()

func random_shout():
	$"../Shouting".stream = shouts[rand_range(0, shouts.size())]
	$"../Shouting".play()
	$"../Shouting/Timer".wait_time = rand_range(3.0, 6.0)
	$"../Shouting/Timer".start()

func _on_Limb_body_entered(body):
	print("Body Entered")
	if(!$AudioStreamPlayer2D.playing and !body.find_parent("Player")):
		random_crash()

