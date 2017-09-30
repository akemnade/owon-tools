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

[DBus (name = "org.bluez.GattProfile1")]
class GattProfile : Object {
	public void release() {
		stderr.printf("profile release\n");
	}
	string [] u_u_i_ds;
	[DBus (visible = false)]
		public GattProfile(string [] uuids) {
		u_u_i_ds = uuids;
	}
	[DBus (visible = false)]
		public HashTable<string,Variant> get_all_prop() {
		var ht = new HashTable<string,Variant>(str_hash, str_equal);
		ht["UUIDs"] = new Variant.strv(u_u_i_ds);
		return ht;
	}
}

[DBus (name = "org.freedesktop.DBus.ObjectManager")]
class FDObjectManager : Object {
	
	public HashTable<GLib.ObjectPath,HashTable<string,HashTable<string,Variant>>> get_managed_objects() {
		var ht = new HashTable<string,HashTable<string,Variant>>(str_hash, str_equal);
		ht["org.bluez.GattProfile1"] = profile.get_all_prop();
		var res = new HashTable<GLib.ObjectPath,HashTable<string,HashTable<string,Variant>>>(str_hash, str_equal);
		res[new ObjectPath("/org/ak/owonmulti/bleprofile")] = ht;
		return res;
		
	}
	[DBus (visible = false)]
	GattProfile profile;
	[DBus (visible = false)]
	public FDObjectManager(GattProfile profile) {
		this.profile = profile;
	}
}

public void register_profile(DBusConnection conn, string uuid)
{
	string [] uuids = {uuid};
	GattProfile gattprof = new GattProfile(uuids);
	org.bluez.GattManager1 manager = conn.get_proxy_sync("org.bluez", "/org/bluez/hci0");
	conn.register_object("/org/ak/owonmulti/bleprofile",
						 gattprof);
	conn.register_object("/org/ak/owonmulti",
						 new FDObjectManager(gattprof));
/*	conn.register_object("/",
						 new FDObjectManager(gattprof));
*/	
	manager.register_application(new ObjectPath("/org/ak/owonmulti"),
								 new GLib.HashTable<string, GLib.Value?>(GLib.str_hash, GLib.str_equal)); 
	
}