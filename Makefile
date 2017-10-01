COMMON_SRCS = register_profile.vala owon_device.vala owon_manager.vala org-bluez-ifaces.vala measurement_result.vala

all: owon-console owon-gui

owon-console: owon-console.vala $(COMMON_SRCS)
	valac $^ --pkg gio-2.0 --pkg posix -g --save-temps --no-color -X -lm
owon-gui: owon-gui.vala $(COMMON_SRCS)
	valac $^ --pkg gio-2.0 --pkg gtk+-2.0 --pkg posix -g --save-temps --no-color -X -lm
