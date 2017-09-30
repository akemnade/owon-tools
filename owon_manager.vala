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
[DBus (name = "org.freedesktop.DBus.ObjectManager")]
interface ObjectManagerCl : Object {
        
	public abstract HashTable<GLib.ObjectPath,HashTable<string,HashTable<string,Variant>>> get_managed_objects(); 
       
}

public class OwonManager {
	DBusConnection conn;
	HashTable<GLib.ObjectPath,HashTable<string,HashTable<string,Variant>>> objs;
	public void discover() throws IOError {
		if (conn == null) {
			conn = Bus.get_sync(BusType.SYSTEM);
		}
		ObjectManagerCl obj_m = conn.get_proxy_sync("org.bluez",
													"/");
		objs = obj_m.get_managed_objects();
	}

	static string? check_valid_service(HashTable<string,Variant> props) {
		var v = props["UUID"];
		if (v == null)
			return null;
		string vstr = v.get_string();
		if (vstr == null)
			return null;
		if (vstr != OwonDevice.uuid)
			return null;
		v = props["Device"];
		if (v == null)
			return null;
		vstr = v.get_string();
		return vstr;
	}
	
	public OwonDevice? get_known(string? addr = null) throws IOError {
		if (objs == null) {
			return null;
		}
		var devs = new HashTable<GLib.ObjectPath,HashTable<string,Variant>>(str_hash, str_equal);
		string [] services = {};
		string [] valid_devices = {};
		var chars = new HashTable<GLib.ObjectPath,HashTable<string,Variant>>(str_hash, str_equal);
		objs.foreach((objpath, interfaces) => {
				var props = interfaces["org.bluez.Device1"];
				if (props != null) {
					devs[objpath] = props;
				}
				props = interfaces["org.bluez.GattService1"];
				if (props != null) {
					string dev = check_valid_service(props);
					if (dev != null) {
						valid_devices += dev;
						services += objpath;
					}
				}
				props = interfaces["org.bluez.GattCharacteristic1"];
				if (props != null) {
					chars[objpath] = props;
				}
			});
		//stdout.printf("services.length %d\n",services.length);
		if (services.length == 0)
			return null;
		ObjectPath [] charpaths = new ObjectPath[5];
		chars.foreach((objpath, props) => {
				do {
/*
					props.foreach((propname, propval) => {
							stdout.printf("%s: %s\n",propname, propval.print(false));
							});
*/
					Variant servvar = props["Service"];
					if (servvar == null)
						break;
					string servstr = servvar.get_string();
					if (servstr == null) 
						break;
					if (servstr != services[0])
						continue;
					Variant uuidvar = props["UUID"];
					if (uuidvar == null)
						continue;
					string uuidstr = uuidvar.get_string();
					if (uuidstr == null)
						continue;
					stdout.printf("char uuid: %s\n", uuidstr);
					uuidstr = uuidstr[4:8];
					if (uuidstr == "fff1")
						charpaths[0] = objpath;
					else if (uuidstr == "fff2")
						charpaths[1] = objpath;
					else if (uuidstr == "fff3")
						charpaths[2] = objpath;
					else if (uuidstr == "fff4")
						charpaths[3] = objpath;
					else if (uuidstr == "fff5")
						charpaths[4] = objpath;
				} while(false);
			});
		for(int i = 0; i < charpaths.length; i++) {
			if (charpaths[i] == null)
				return null;
		}
		return OwonDevice.connect_via_pathlist(conn, new ObjectPath(services[0]),
											  charpaths);
	}
   
}
