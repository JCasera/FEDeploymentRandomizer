extends PopupPanel

@onready var unit_preview = $VBox/UnitPreview
@onready var unit_selector = $VBox/UnitSelector
@onready var class_selector = $VBox/ClassSelector
@onready var confirm_btn = $VBox/ConfirmBtn

var unit_position = 0

signal custom_unit_selected(unit_name : String, unit_class : String, unit_position : int)

func _ready():
	var file = FileAccess.open("res://class_list.json", FileAccess.READ)
	for c in JSON.parse_string(file.get_as_text()):
		class_selector.add_item(c)
	
	
	confirm_btn.pressed.connect(signal_unit_selected)

func init(available_units : Array, current_unit : String, current_class : String, current_position : int) -> void:
	unit_selector.clear()
	for i in available_units:
		unit_selector.add_item(i)
		if i == current_unit:
			unit_selector.select(unit_selector.item_count - 1)
	
	# Temp for class selection
	for c in class_selector.item_count:
		if class_selector.get_item_text(c) == current_class:
			class_selector.select(c)
	
	unit_position = current_position

func signal_unit_selected() -> void:
	emit_signal("custom_unit_selected", unit_selector.get_item_text(unit_selector.selected), class_selector.get_item_text(class_selector.selected), unit_position)
	hide()
