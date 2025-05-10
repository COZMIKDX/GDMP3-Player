extends Node2D
var musicLabelScene = load("res://music_label.tscn")
# var numberOfLabels = 0
var scrollSpeed = 0.0
@export var scrollAccel = 0.001
@export var scrollDecel: float = 0.00001

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_label("Pumpkin Hill.mp3")
	add_label("1.exe")
	add_label("2.wav")
	add_label("3.stl")
	
	var pointsArray = $OrbitalPath.curve.get_baked_points()
	$Visual.points = pointsArray


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("scroll up"):
		scrollSpeed = scrollSpeed + scrollAccel
	if Input.is_action_just_released("scroll down"):
		scrollSpeed = scrollSpeed - scrollAccel
	
	if not is_zero_approx(scrollSpeed):
		if scrollSpeed > 0.0:
			scrollSpeed = scrollSpeed - scrollDecel
		elif scrollSpeed < 0.0:
			scrollSpeed = scrollSpeed + scrollDecel
	
	scroll_up(scrollSpeed)
	

func add_label(name):
	var newMusicLabel = musicLabelScene.instantiate()
	newMusicLabel.setText(name)
	$Labels.add_child(newMusicLabel)
	
	var newFollower = PathFollow2D.new()
	newFollower.rotates = false
	
	var newRemoteTransform = RemoteTransform2D.new()
	newRemoteTransform.remote_path = newMusicLabel.get_path()
	newRemoteTransform.update_rotation = false
	newRemoteTransform.update_scale = false
	
	newFollower.add_child(newRemoteTransform)
	$OrbitalPath.add_child(newFollower)
	
	updateSpacing()

func updateSpacing():
	var numberOfLabels = $Labels.get_child_count()
	var spacing = 1.0 / numberOfLabels
	
	var followers = $OrbitalPath.get_children()
	for i in range(followers.size()):
		followers[i].progress_ratio = spacing * i
		
func scroll_up(speed):
	var followers = $OrbitalPath.get_children()
	for i in range(followers.size()):
		followers[i].progress_ratio = followers[i].progress_ratio + speed


func _on_button_pressed() -> void:
	scroll_up(0.01)
