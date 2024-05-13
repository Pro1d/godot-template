class_name MapAreaInspectorPlugin
extends EditorInspectorPlugin

func _can_handle(object: Variant) -> bool:
	return object is MapArea

func _parse_property(
	object: Object,
	type: Variant.Type,
	name: String,
	hint_type: PropertyHint,
	hint_string: String,
	usage_flags: int, # BitField[PropertyUsageFlags]
	wide: bool
) -> bool:
	if type == TYPE_OBJECT and NeighborMapAreaEditorProperty.property_to_direction(name) != -1:
		add_property_editor(name, NeighborMapAreaEditorProperty.new(), true)
		return false
	else:
		return false
