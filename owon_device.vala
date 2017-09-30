/********************************************************************** 
 owon-tools - Copyright (C) 2017 - Andreas Kemnade
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 3, or (at your option)
 any later version.
             
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
***********************************************************************/

public class OwonDevice : GLib.Object {
	org.bluez.GattCharacteristic1 [] chars;
	org.bluez.Device1 device;
	public const string uuid = "0000fff0-0000-1000-8000-00805f9b34fb";
	public void start_measure() throws IOError {
		chars[3].start_notify();
	}

	public void stop_measure() throws IOError {
		chars[3].stop_notify();
	}

	public bool is_connected() {
		return device.connected;
	}
	
	public signal void got_measurement(MeasurementResult res);

	void got_measurement_noti(Variant changed_properties,
							  string[] invalidated_properties) {
		//	stdout.printf("changed props: %s\n", changed_properties.print(true));
		Variant val = changed_properties.lookup_value("Value", VariantType.BYTESTRING);
		if (val != null) {
			int i;
			uint8 [] value = new uint8[val.n_children()];
			//	stdout.printf("changed value: %s\n", val.print(true));
			for(i = 0; i < value.length; i++) {
				value[i]=val.get_child_value(i).get_byte();
			}
			MeasurementResult res = new MeasurementResult(value);
			if (res.valid)
				got_measurement(res);
		}
	}
	
	public static OwonDevice? connect_via_pathlist(GLib.DBusConnection conn, GLib.ObjectPath servicepath, GLib.ObjectPath [] charpaths) throws IOError {
		int i;
		org.bluez.GattCharacteristic1 [] chars = new org.bluez.GattCharacteristic1[charpaths.length];
		for(i = 0; i < charpaths.length; i++) {
			chars[i] = conn.get_proxy_sync("org.bluez",
										   charpaths[i]);
		}
		org.bluez.GattService1 service = conn.get_proxy_sync("org.bluez",
															 servicepath);
		if (service.u_u_i_d != uuid)
		return null;
		org.bluez.Device1 device = conn.get_proxy_sync("org.bluez",
														   service.device);
		return new OwonDevice(device, chars);
	}
	
	public class OwonDevice(org.bluez.Device1 device,
							org.bluez.GattCharacteristic1 [] chars) {
		this.chars = chars;
		this.device = device;
		(chars[3] as DBusProxy).g_properties_changed.connect(got_measurement_noti);
	}
}