extends CanvasLayer
class_name Keypad

signal code_submitted(code: String)

@onready var display: LineEdit = $PanelContainer/VBoxContainer/LineEdit
@onready var grid: GridContainer = $PanelContainer/VBoxContainer/GridContainer

func _ready() -> void:
	# 1. Povezivanje klikova na dugmiće na ekranu (kao i do sada)
	for button in grid.get_children():
		if button is Button:
			button.pressed.connect(_on_button_pressed.bind(button.text))
			
	# 2. Povezivanje signala sa LineEdit-a za kucanje preko tastature
	display.text_changed.connect(_on_display_text_changed)
	display.text_submitted.connect(_on_display_text_submitted)
	
	# 3. Automatski "klikni" na ekran da igrač može odmah da kuca bez miša
	display.grab_focus()
	
	process_mode = PROCESS_MODE_ALWAYS
	get_tree().paused = true


func _on_button_pressed(button_text: String) -> void:
	match button_text:
		"C":
			display.text = ""
		"OK":
			submit_and_close()
		_:
			if display.text.length() < 4:
				display.text += button_text


# Funkcija koja se aktivira na SVAKO slovo/broj koji igrač ukuca preko tastature
func _on_display_text_changed(new_text: String) -> void:
	# Filter: Dozvoljavamo samo cifre (0-9)
	var filtered_text = ""
	for character in new_text:
		if character.is_valid_int():
			filtered_text += character
			
	# Ako je ukucano više od 4 cifre, odseci višak
	if filtered_text.length() > 4:
		filtered_text = filtered_text.substr(0, 4)
		
	# Vrati filtrirani tekst nazad u ekran (ovo sprečava kucanje slova)
	display.text = filtered_text
	
	# Pomeri kursor na kraj teksta da kucanje ide glatko
	display.caret_column = display.text.length()


# Funkcija koja se aktivira kada igrač pritisne ENTER na tastaturi
func _on_display_text_submitted(_new_text: String) -> void:
	submit_and_close()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_keypad()


# Izdvojena logika za slanje koda da je ne bismo ponavljali
func submit_and_close() -> void:
	code_submitted.emit(display.text)
	close_keypad()


func close_keypad() -> void:
	get_tree().paused = false
	queue_free()
