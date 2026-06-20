extends CanvasLayer

@onready var naslov_label = $CenterContainer/PanelContainer/VBoxContainer/Label
@onready var tekst_label = $CenterContainer/PanelContainer/MarginContainer/Label2

func _ready():
	hide()
	# Ovo osigurava da konzola radi i kada je igra pauzirana
	process_mode = Node.PROCESS_MODE_ALWAYS

func open(naslov: String, tekst: String):
	naslov_label.text = naslov
	tekst_label.text = tekst
	show()
	get_tree().paused = true

func _input(event):
	# Ako je konzola vidljiva i pritisnut je Space, zatvori je
	if visible and event.is_action_pressed("ui_accept"):
		close_console()

func close_console():
	hide()
	get_tree().paused = false

# Možeš zadržati i dugme, samo pozovi istu funkciju
func _on_button_pressed():
	close_console()
