# owon-tools
Tools for accessing OWON multimeters like OWON B35T via BLE

Build:
-----
requires vala and gtk2

make

owon-console 
-------------

Displays measurements as console outputs.

usage
owon-console [--autoconnect]

If --autoconnect is set, it will try to discover owon devices and connect to one,
without it it will just use known, connected devices. It registers a gatt profile,
so that bluez will connect any known device with that profile 

owon-gui

graphical user interface, provides buttons with the same functions as on the multimeter
itself.
