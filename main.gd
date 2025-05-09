extends Node2D

var currentDir = ""
var filename = "lupin.mp3"
var audioFilesList = []
var audioIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadInfo()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_open_file_button_pressed() -> void:
	$FileDialog.popup_centered()

func _on_file_dialog_dir_selected(dir: String) -> void:
	currentDir = dir
	updateFilesList(dir)
	saveInfo()

func updateFilesList(dir):
	var targetDir = DirAccess.open(dir)
	var allFiles = targetDir.get_files()
	audioFilesList.clear()
	for file in allFiles:
		if file.ends_with(".mp3") or file.ends_with(".wav") or file.ends_with(".ogg"):
			audioFilesList.push_back(file)

	if not audioFilesList.is_empty():
		load_audio()
	else: 
		updateTitleDisplay("No audio files in directory.")

func load_mp3(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var sound = AudioStreamMP3.new()
	sound.data = file.get_buffer(file.get_length())
	return sound
	
func load_wav(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var sound = AudioStreamWAV.new()
	sound.data = file.get_buffer(file.get_length())
	return sound

func load_ogg(path):
	return AudioStreamOggVorbis.load_from_file(path)

func load_audio():
	if audioFilesList.size() == 0:
		return
		
	var stream
	var audioPath = filePath(audioFilesList[audioIndex])
	var extension = audioPath.get_slice(".", 1)
	match extension:
		#"wav": # wavs aren't working rn.
			#stream = load_wav(audioPath)
		"mp3":
			stream = load_mp3(audioPath)
		"ogg":
			stream = load_ogg(audioPath)
	
	$AudioPlayer.stream = stream
	updateTitleDisplay(audioFilesList[audioIndex])
	
func filePath(path):
	return currentDir + "/" + path

func next_song():
	if audioFilesList.is_empty():
		return
	
	audioIndex = audioIndex + 1
	if audioIndex > audioFilesList.size() - 1:
		audioIndex = audioFilesList.size() - 1
		
	load_audio()
	updateTitleDisplay(audioFilesList[audioIndex])
	
func prev_song():
	if audioFilesList.is_empty():
		return
	
	audioIndex = audioIndex - 1
	if audioIndex < 0:
		audioIndex = 0
		
	load_audio()
	updateTitleDisplay(audioFilesList[audioIndex])

func updateTitleDisplay(text):
	$TitleName.text = text

func saveInfo():
	var saveFile = FileAccess.open("user://playerSettings.config", FileAccess.WRITE)
	var settings = {}
	settings["lastDirectory"] = currentDir
	saveFile.store_line(JSON.stringify(settings))

func loadInfo():
	if not FileAccess.file_exists("user://playerSettings.config"):
		return
	
	var saveFile = FileAccess.open("user://playerSettings.config", FileAccess.READ)
	var fileString = saveFile.get_as_text()
	var json = JSON.new()
	var result = json.parse(fileString)
	if not result == OK:
		return
	
	currentDir = json.data.lastDirectory
	$FileDialog.current_dir = currentDir
	updateFilesList(currentDir)

func _on_play_button_pressed() -> void:
	if $AudioPlayer.playing:
		$AudioPlayer.stream_paused = true
	elif $AudioPlayer.stream_paused:
		$AudioPlayer.stream_paused = false
	elif !$AudioPlayer.playing:
		$AudioPlayer.play()

func _on_next_button_pressed() -> void:
	next_song()

func _on_prev_button_pressed() -> void:
	prev_song()

func _on_v_slider_value_changed(value: float) -> void:
	$AudioPlayer.volume_db = value
