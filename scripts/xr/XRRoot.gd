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

func center_player_on(p_transform : Transform3D) -> void:
	# In order to center our player so the players feet are at the location
	# indicated by p_transform, and having our player looking in the required
	# direction, we must offset this transform using the cameras transform.

	# So we get our current camera transform in local space
	var camera_transform := _camera.transform

	# We obtain our view direction and zero out our height
	var view_direction := camera_transform.basis.z
	view_direction.y = 0

	# Now create the transform that we will use to offset our input with
	var t : Transform3D
	t = t.looking_at(-view_direction, Vector3.UP)
	t.origin = camera_transform.origin
	t.origin.y = 0

	# And now update our origin point
	global_transform = (p_transform * t.inverse()).orthonormalized()

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
