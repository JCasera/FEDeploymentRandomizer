extends MarginContainer

@onready var sprite = $Info/Images/Sprite
@onready var lock = $Info/Images/Locked
@onready var unit_label = $Info/Name
@onready var unit_class = $Info/Class

var locked = false
var index = -1

signal select_unit_to_display(current_unit : String, current_class : String, unit_position : int)

func _ready():
	sprite.gui_input.connect(register_click)

func get_unit() -> String:
	return unit_label.text

func set_unit(unit_name : String) -> void:
	if unit_name.ends_with(".import"):
		unit_name = unit_name.get_basename()
	unit_label.text = unit_name.get_basename()
	sprite.texture = ResourceLoader.load("res://Images/EngageSprites/" + unit_name)

func set_unit_class(unit_class_name : String) -> void:
	unit_class.text = unit_class_name

func clear_unit() -> void:
	unit_label.text = ""
	unit_class.text = ""
	sprite.texture = null
	lock.hide()
	
func toggle_locked_status() -> void:
	if locked:
		locked = false
		lock.hide()
	else:
		locked = true
		lock.show()

func register_click(ev : InputEvent) -> void:
	if ev is InputEventMouseButton and ev.is_pressed():
		if ev.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("select_unit_to_display", unit_label.text, unit_class.text, index)
		if ev.button_index == MOUSE_BUTTON_MASK_RIGHT:
			toggle_locked_status()
