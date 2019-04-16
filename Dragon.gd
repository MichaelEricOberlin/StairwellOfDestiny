extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (float) var highest = 50.0
export (float) var lowest = -50.0
export (float) var health = 100.0

var center
var live := true

#number of jaw-opens before fire breath
var next_fire_breath := -1
var total_jaw_opens_so_far := 0
var jaw_was_opening := false
var last_jaw_rot := 0.0
var time_of_death
var pos_of_death
onready var floor_pos = get_viewport().size.y #OS.get_window_size().y

onready var fire_prefab = preload("res://Fire Breath.tscn")
onready var explosion_prefab = preload("res://Explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Floor: " + str(floor_pos))
	randomize()
	center = self.position
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if($"/root/Game/Stairwell".rolling):
		if(live):
			if(total_jaw_opens_so_far > next_fire_breath):
				next_fire_breath += rand_range(1, 4)
				
				if(next_fire_breath != 0):
					$"/root/Game/Fire Breath".reset()
					$"Fire Breath".play()
			
			#Handle jaw, keep track of how many times it's opened
			var jaw = $Body/Jaw
			last_jaw_rot = jaw.rotation
			jaw.rotation = lerp(-PI / 8.0, -PI / 4.0, (cos(3 * OS.get_ticks_msec()/1000.0) + 1.0) / 2.0)
			if(jaw_was_opening and jaw.rotation < last_jaw_rot):
				total_jaw_opens_so_far += 1
				jaw_was_opening = false
			elif(not jaw_was_opening and jaw.rotation > last_jaw_rot):
				jaw_was_opening = true
			
			$"Body/Wing (B)".rotation = PI/4.0 * lerp(0.0, -PI/3.0, (-sin(OS.get_ticks_msec()/1000.0) + 1.0) / 2.0)
			$"Body/Wing (F)".rotation = PI/4.0 * lerp(0.0, PI/3.0, (-sin(OS.get_ticks_msec()/1000.0) + 1.0) / 2.0)
		
		if(live):
			self.position.y = center.y + lerp(highest, lowest, cos(OS.get_ticks_msec()/1000.0))
		else:
			self.position.y = lerp(pos_of_death, floor_pos, ((OS.get_ticks_msec() - time_of_death)/1000.0)/5.0)
	else:
		$"Body/Wing (B)".rotation = PI/4.0 * lerp(0.0, -PI/3.0, (-sin(OS.get_ticks_msec()/1000.0) + 1.0) / 2.0)
		$"Body/Wing (F)".rotation = PI/4.0 * lerp(0.0, PI/3.0, (-sin(OS.get_ticks_msec()/1000.0) + 1.0) / 2.0)

func _on_Dragon_body_entered(body):
	var player = body.find_parent("Player")
	if(player):
		if(body.position.y < self.position.y - $CollisionShape2D.shape.radius/2.0):
			decrement_health(25.0)
		else:
			player.get_node("Torso").decrement_health(25.0)
		body.apply_impulse(Vector2(), Vector2(-4000.0, 0.0))
	pass # Replace with function body.

func decrement_health(dec):
	health -= dec
	
	$"/root/Game/ColorRect/Dragon Health".rect_size.x = (health / 100.0) * 200
	
	if(health <= 0.0 and $"/root/Game/Player/Torso".live):
		explode()

func explode():
	live = false
	time_of_death = OS.get_ticks_msec()
	pos_of_death = self.position.y
	$"Explosion Timer".start()
	$"/root/Game/Victory".show()
	#self.mode = RigidBody2D.MODE_RIGID
	#self.gravity_scale = 10.0

func _on_Explosion_Timer_timeout():
	var splode = explosion_prefab.instance()
	splode.frame = 0
	splode.position = $CollisionShape2D.get_relative_transform_to_parent($"/root/Game").origin + randf() * $CollisionShape2D.shape.radius * Vector2(1.0, 0.0).rotated(rand_range(-PI, PI))
	$"/root/Game".add_child(splode)
	pass # Replace with function body.
