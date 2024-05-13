@tool
extends EditorPlugin

var map_area_inspector_plugin : MapAreaInspectorPlugin

func _enter_tree() -> void:
	map_area_inspector_plugin = MapAreaInspectorPlugin.new()
	add_inspector_plugin(map_area_inspector_plugin)

func _exit_tree() -> void:
	remove_inspector_plugin(map_area_inspector_plugin)
