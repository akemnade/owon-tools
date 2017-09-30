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

namespace org {
	namespace bluez {
		[DBus (name = "org.bluez.GattCharacteristic1", timeout = 120000)]
		public interface GattCharacteristic1 : GLib.Object {
			
			public abstract uint8[] read_value(GLib.HashTable<string, Variant> options) throws DBusError;
			public abstract void write_value(uint8[] value, GLib.HashTable<string, Variant> options) throws DBusError;
			public abstract void start_notify() throws IOError;
			public abstract void stop_notify() throws IOError;
			public abstract string u_u_i_d { owned get; set; }
			public abstract ObjectPath service { owned get; set; }
			public abstract uint8[] value { owned get; set; }
			public abstract bool notifying {  get; set; }
			public abstract string[] flags { owned get; set; }
		}
		
		[DBus (name = "org.bluez.GattManager1", timeout = 120000)]
		public interface GattManager1 : GLib.Object {
			public async abstract void register_application(ObjectPath application, GLib.HashTable<string, Variant> options) throws IOError;
			public abstract void unregister_application(ObjectPath application) throws IOError;
		}
		
		[DBus (name = "org.bluez.GattService1", timeout = 120000)]
		public interface GattService1 : GLib.Object {
			public abstract string u_u_i_d { owned get; set; }
			public abstract GLib.ObjectPath device { owned get; set; }
			public abstract bool primary {  get; set; }
		}

		[DBus (name = "org.bluez.Device1", timeout = 120000)]
		public interface Device1 : GLib.Object {
			public abstract void disconnect() throws IOError;
			public abstract void connect() throws IOError;
			public abstract void connect_profile(string UUID) throws IOError;
			public abstract void disconnect_profile(string UUID) throws IOError;
			public abstract void pair() throws IOError;
			public abstract void cancel_pairing() throws IOError;
			public abstract string address { owned get; set; }
			public abstract string name { owned get; set; }
			public abstract string alias { owned get; set; }
			[DBus (name = "Class")]
			public abstract uint class_ {  get; set; }
			public abstract uint appearance {  get; set; }
			public abstract string icon { owned get; set; }
			public abstract bool paired {  get; set; }
			public abstract bool trusted {  get; set; }
			public abstract bool blocked {  get; set; }
			public abstract bool legacy_pairing {  get; set; }
			public abstract int16 r_s_s_i {  get; set; }
			public abstract bool connected {  get; set; }
			public abstract string[] u_u_i_ds { owned get; set; }
			public abstract string modalias { owned get; set; }
			public abstract GLib.ObjectPath adapter { owned get; set; }
			public abstract GLib.HashTable<uint, GLib.Variant> manufacturer_data { owned get; set; }
			public abstract GLib.HashTable<string, GLib.Variant> service_data { owned get; set; }
			public abstract int16 tx_power {  get; set; }
			public abstract bool services_resolved {  get; set; }
		}

	}
}