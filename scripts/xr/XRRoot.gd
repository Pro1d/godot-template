class_name XRRoot
extends XROrigin3D

@export var _passtrough := false

var xr_interface: XRInterface

@onready var _camera := %XRCamera3D as XRCamera3D
#@onready var _left_controller := %XRControllerLeft as XRController3D
#@onready var _right_controller := %XRControllerRight as XRController3D

func _ready() -> void:
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
		
		set_passthrough(_passtrough)
	else:
		print("OpenXR not initialized, please check if your headset is connected")

func center_world_on_camera(origin: Vector3 = Vector3.ZERO) -> void:
	var pos := _camera.position
	pos.y = 0
	position = origin - pos

func align_world_to(t: Transform2D) -> void:
	# Assuming there is no scale in the transform
	var t_inv := t.affine_inverse()
	transform = Geometry.to_transform_3d(t_inv) * transform

func set_passthrough(on: bool) -> bool:
	var success := true
	if xr_interface.is_passthrough_supported():
		if xr_interface.is_passthrough_enabled() != on:
			if on:
				success = xr_interface.start_passthrough()
			else:
				xr_interface.stop_passthrough()
	else:
		var modes := xr_interface.get_supported_environment_blend_modes()
		var mode := xr_interface.XR_ENV_BLEND_MODE_ALPHA_BLEND if on else xr_interface.XR_ENV_BLEND_MODE_OPAQUE
		if mode not in modes:
			success = false
		else:
			xr_interface.set_environment_blend_mode(mode)
	
	if success:
		get_viewport().transparent_bg = on
	return success
