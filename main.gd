extends VBoxContainer

@onready var deployment_grid = $DeploymentGrid

@onready var randomize_btn = $Menu/Randomize
@onready var clear_units_btn = $Menu/ClearAll
@onready var deployment_count = $Menu/UnitCount
@onready var set_available_units_btn = $Menu/SetAvailableUnits
@onready var transparent_toggle = $Menu/TransparentBG

@onready var unit_toggle_popup = $UnitToggles
@onready var unit_toggle_grid = $UnitToggles/VBox/Grid
@onready var close_popup = $UnitToggles/VBox/Close

@onready var unit_selection_popup = $UnitSelect

var UnitDisplay = preload("res://unit_display.tscn")

var toggle_row = load("res://toggle_row.tscn")

var unit_list = {} #Name: Available?
var available_unit_count = 0
var row_max = 7
var current_deployment = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in DirAccess.get_files_at("res://FE-Engage-Sprites"):
		if i == "Alear.png":
			continue
		if i.ends_with(".png"):
			unit_list[i] = true
			add_unit_to_availability_toggle(i)
			available_unit_count += 1
			
	deployment_grid.columns = row_max
	for u in range(1, deployment_grid.get_child_count(), 1):
		var slot = deployment_grid.get_child(u)
		slot.select_unit_to_display.connect(customize_unit)
		slot.index = u
		slot.clear_unit()
	deployment_grid.get_child(0).set_unit("Alear.png")
	deployment_grid.get_child(0).unit_class.text = ""
	deployment_grid.get_child(0).toggle_locked_status()

	randomize_btn.pressed.connect(select_units)
	clear_units_btn.pressed.connect(clear_units)
	set_available_units_btn.pressed.connect(display_unit_availablity_toggle)
	transparent_toggle.toggled.connect(set_transparent_bg)
	close_popup.pressed.connect(unit_toggle_popup.hide)
	
	
	unit_selection_popup.custom_unit_selected.connect(select_custom_unit)
	unit_selection_popup.exclusive = true
	
func select_units():
	clear_units()
	current_deployment = []
	var max_units = min(deployment_count.value, available_unit_count)
	for j in max_units:
		var unit = "Alear.png"
		
		if deployment_grid.get_child(j).locked:
			continue
		
		if j > 0:
			unit = unit_list.keys().pick_random()
			while unit in current_deployment || unit_list[unit] == false:
				unit = unit_list.keys().pick_random()
				
		current_deployment.append(unit)
	
		deployment_grid.get_child(j).set_unit(unit)

func select_custom_unit(unit_name : String, unit_class : String, unit_position : int) -> void:
	var slot = deployment_grid.get_child(unit_position)
	slot.set_unit(unit_name)
	slot.set_unit_class(unit_class)
	if not slot.locked:
		slot.toggle_locked_status()

func customize_unit(current_unit : String, current_class : String, unit_position : int) -> void:
	var available_deployments = []
	for i in unit_list.keys():
		if unit_list[i] and not i in current_deployment:
			available_deployments.append(i)
	
	unit_selection_popup.init(available_deployments, current_unit, current_class, unit_position)
	unit_selection_popup.popup_centered(Vector2i(500,500))

func clear_units() -> void:
	for y in deployment_grid.get_children():
		if y.locked:
			continue
		y.clear_unit()
	
func add_unit_to_availability_toggle(unit_name : String) -> void:
	var row = toggle_row.instantiate()
	unit_toggle_grid.add_child(row)
	row.unit_name.text = unit_name.get_basename()
	row.toggle.button_pressed = true
	row.toggle.toggled.connect(update_unit_availaibity.bind(unit_name))

func update_unit_availaibity(toggle_on : bool, unit_name : String) -> void:
	unit_list[unit_name] = toggle_on
	if toggle_on:
		available_unit_count = min(unit_list.keys().size(), available_unit_count+1)
	else:
		available_unit_count = max(0, available_unit_count-1)

func display_unit_availablity_toggle() -> void:
	unit_toggle_popup.popup_centered(size)

func set_transparent_bg(checked : bool) -> void:
	get_viewport().transparent_bg = checked
