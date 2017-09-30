COMMON_SRCS = register_profile.vala owon_device.vala owon_manager.vala org-bluez-ifaces.vala measurement_result.vala
owon-console: owon-console.vala $(COMMON_SRCS)
	valac $^ --pkg gio-2.0 -g --save-temps --no-color -X -lm
