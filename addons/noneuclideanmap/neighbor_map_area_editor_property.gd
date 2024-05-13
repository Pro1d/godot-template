class_name NeighborMapAreaEditorProperty
extends EditorProperty

const MapAreaResource := preload("res://scenes/xr/MapArea.tscn")

static func property_to_direction(property: String) -> int:
	return [
		"neighbor_X_plus", "neighbor_Y_plus",
		"neighbor_X_minus", "neighbor_Y_minus"
	].find(property)

var _label_node_name := Label.new()
var _button_create := Button.new()
var _container := HBoxContainer.new()
var _current_value : MapArea

func _init() -> void:
	var gui := EditorInterface.get_base_control()
	var add_icon := gui.get_theme_icon("Add", "EditorIcons")
	_container.size_flags_horizontal = Control.SIZE_FILL
	_button_create.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#_label_node_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#_label_node_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_button_create.icon = add_icon
	_button_create.text = "Create New Tile"
	#_container.add_child(_label_node_name)
	#_container.add_child(_button_create)
	#_container.add_child(_button_clear)
	#add_child(_container)
	add_child(_button_create)
	add_focusable(_button_create)
	_update_display()
	
	_button_create.pressed.connect(_on_create_pressed)

func _set_read_only(read_only: bool) -> void:
	_button_create.disabled = read_only

func _update_property() -> void:
	label = ""
	# Read the current value from the property.
	var new_value = get_edited_object()[get_edited_property()]
	if (new_value == _current_value):
		return

	# Update the control with the new value.
	#updating = true
	_current_value = new_value
	_update_display()
	#updating = false

func _update_display() ->  void:
	# _label_node_name.text = _current_value.name if _current_value != null else "-"
	_button_create.disabled = read_only or _current_value != null

func _on_create_pressed() -> void:
	var current_area := get_edited_object() as MapArea
	var dir := NeighborMapAreaEditorProperty.property_to_direction(get_edited_property())
	
	# Sanity check
	if dir == -1 or EditorInterface.get_edited_scene_root() == current_area:
		return
	
	# Create the neighboring area
	var new_neighbor := MapAreaResource.instantiate()
	new_neighbor.position = (
		current_area.position
		+ Geometry.to_vector3(Geometry.to_direction_vector(dir))
	).round()
	current_area.add_sibling(new_neighbor, true)
	new_neighbor.set_owner(EditorInterface.get_edited_scene_root())
	#new_neighbor.neighbor_drop = current_area
	current_area.neighbor_drop = new_neighbor
	# Update property editor
	_current_value = new_neighbor
	_update_display()
	emit_changed(get_edited_property(), _current_value)
