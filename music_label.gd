extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# input should have a file extension with it.
func setText(text: String):
	if text.is_empty():
		return
		
	var tokens = text.split(".")
	$ExtensionLabel.text = tokens[tokens.size() - 1]
	$Label.text = ".".join(tokens.slice(0, tokens.size() - 1)) # put any . that were in the file but not for the extension.
