extends Node2D

export (float) var vertical_step = 10.0

export (float) var min_rotation = -PI/16.0
export (float) var max_rotation = PI/16.0
export (float) var rotation_speed = 5.0
export (float) var speed = 200.0

export (float) var min_speed = 100.0

var target_rot = 0.0
var progress = 0.0
var progress_speed = 1.0
var progress_speed_A = 1.0
var progress_speed_B = 1.0

#Idea: have it lerp, by working with wavelength instead.
#Time of next random change in progress speed, relative to game start
var next_progress_speed_change = 0.1
var last_progress_change_flag = 0.0

export (float) var end_height = 100.0 setget set_end_height, get_end_height
export (float) var start_height = 200.0 setget set_start_height, get_start_height
var orig_end_height
var orig_start_height
var slope := 0.0
var move_dir = Vector2(1.0, 0.0)

onready var screensize = get_viewport().get_visible_rect().size
onready var stair_prefab = preload("res://Stair.tscn")
onready var door = $Door
onready var cat = $"Whiskers MacKillface"
onready var decor = $Decor
var stairs := []
var active_stairs := []

var width = 0
var height = 0

var rolling := false

# Called when the node enters the scene tree for the first time.
func _ready():
	orig_end_height = end_height
	orig_start_height = start_height
	door.position.y = orig_start_height - door.get_node("Sprite").texture.get_height()/2.0#75.0 - door.get_node("Sprite").texture.get_height()/2.0
	cat.position.y = orig_start_height - 1.0 * cat.get_node("Sprite").texture.get_height()/3.0
	
	calc_slope()
	
	randomize()
	
	while(width < screensize.x * 1.5):
		var stair = stair_prefab.instance()
		#stair.position.y = orig_start_height
		stairs.append(stair)
		active_stairs.append(stair)
		init_stair(stair)
		stair.position.y = lerp(orig_end_height, orig_start_height, stair.position.x / get_viewport().get_size().x) + stair.texture.get_size().y/2.0
		add_child(stair)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rolling:
		#start by handling variations in progression speed, and determination of actual progress made
		progress += progress_speed * delta #OS.get_ticks_msec()/1000.0
		progress_speed = lerp(progress_speed_A, progress_speed_B, \
			(progress - last_progress_change_flag)/(next_progress_speed_change - last_progress_change_flag))
		
		if(progress > next_progress_speed_change):
			next_progress_speed_change += randf() * 10.0
			progress_speed_A = progress_speed_B
			progress_speed_B = lerp(0.5, 2.0, randf())
			
		end_height = orig_end_height + (cos(progress - PI) - 1.0)/2.0 * 75.0 # cos(OS.get_ticks_msec()/1000.0) * 75.0
		start_height = orig_start_height + (sin(progress - 3.0 * PI / 2.0) - 1.0)/2.0 * 75.0 #sin(OS.get_ticks_msec()/1000.0) * 25.0
		calc_slope()
		
		var current_speed = min_speed + speed * (cos(progress - PI) + 1.0)/2.0 #(cos(OS.get_ticks_msec()/1000.0) + 1.0)/2.0
		for stair in active_stairs:
			stair.position.y = slope * stair.position.x + start_height
			stair.position -= current_speed * move_dir
			pass
		door.position -= current_speed * move_dir
		cat.position -= current_speed * move_dir
		decor.position -= current_speed * move_dir
	
	#reset any stair that's passed the edge of the screen (basically object pooling)
	if(active_stairs[0].position.x < - active_stairs[0].texture.get_size().x): #rect_size.x):
		var stair = active_stairs.pop_front()
		set_stair_at_end(stair)
		active_stairs.push_back(stair)
	
	pass

func set_stair_at_end(stair):
	#stair.rect_position.x = screensize.x
	var last_stair = active_stairs[active_stairs.size() - 1]
	stair.position.x = last_stair.position.x + last_stair.texture.get_size().x #rect_size.x
	stair.position.y = end_height

func init_stair(stair):
	stair.position.x = width
	width += stair.texture.get_size().x #rect_size.x
	#height += vertical_step
	
func get_end_height():
	return end_height
	
func set_end_height(value):
	end_height = value
	calc_slope()
	
func get_start_height():
	return start_height
	
func set_start_height(value):
	start_height = value
	calc_slope()

func calc_slope():
	slope = (start_height - end_height)/screensize.x
	move_dir = Vector2(1.0, 0.0).rotated(atan(slope)) / 10.0