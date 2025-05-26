extends Control
@export_file("*.json") var d_file
signal dialogoFin
var dialogo = []
var currentDialogoID = 0
var dActivo = false 

func _ready():
	$NinePatchRect.visible= false

func  start():
	print("funciona")
	if dActivo:
		return
	dActivo=true
	$NinePatchRect.visible = true
	dialogo= load_dialogue()
	currentDialogoID = -1
	next_script()
	
func load_dialogue():
	var file = FileAccess.open("res://dialogo/nahualDialogo1.json", FileAccess.READ)
	var content= JSON.parse_string(file.get_as_text())
	return content

func _input(event):
	if !dActivo:
		return
	if event.is_action_pressed("ui_accept"):
		next_script()
func next_script():
	currentDialogoID +=1
	if currentDialogoID >= len(dialogo):
		dActivo=false
		$NinePatchRect.visible = false
		emit_signal("dialogoFin")
		return 
	
	$NinePatchRect/name.text = dialogo[currentDialogoID]['name']
	$NinePatchRect/texto.text = dialogo[currentDialogoID]['text']
