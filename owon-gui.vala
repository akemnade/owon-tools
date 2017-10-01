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

public class OwonDisplay : Gtk.Window {
	Gtk.Button connectbutton;
	bool searching;
	Gtk.Label measurementlabel;
	OwonDevice owondev;
	OwonManager owonmanager;
	Gtk.Button owon_select;
	Gtk.Button owon_range;
	Gtk.Button owon_hold;
	Gtk.Button owon_delta;
	Gtk.Button owon_hz_duty;
	Gtk.Button owon_maxmin;
	Gtk.Button search;

	void display_measurement(MeasurementResult res) {
		measurementlabel.set_text(res.print_value());
	}
	
	void get_connected() {
		try {
			owonmanager.discover();
			owondev = owonmanager.get_known();
			if (owondev != null) {
				owondev.got_measurement.connect(display_measurement);
				owondev.start_measure();
			}
		} catch (IOError e) {
			measurementlabel.set_text("error getting device:\n%s".printf(e.message)); 
		}
	}
	
	public OwonDisplay() {
//		base(Gtk.WindowType.TOPLEVEL);
		var vbox = new Gtk.VBox(false, 0);
		var hboxtop = new Gtk.HBox(false, 0);
		base.add(vbox);
		vbox.pack_start(hboxtop, false, true,0);
		owon_select = new Gtk.Button.with_label("Select");
		hboxtop.pack_start(owon_select, true, true, 0);
		owon_range = new Gtk.Button.with_label("Range");
		hboxtop.pack_start(owon_range, true, true, 0);
		owon_hold = new Gtk.Button.with_label("Hold");
		hboxtop.pack_start(owon_hold, true, true, 0);
		owon_delta = new Gtk.Button.with_label("Delta");
		hboxtop.pack_start(owon_delta, true, true, 0);
		owon_hz_duty = new Gtk.Button.with_label("Hz/Duty");
		hboxtop.pack_start(owon_hz_duty, true, true, 0);
		owon_maxmin = new Gtk.Button.with_label("Max/Min");
		hboxtop.pack_start(owon_maxmin, true, true, 0);
		measurementlabel = new Gtk.Label("not connected");
		vbox.pack_start(measurementlabel, true ,true, 0);
		var hboxbottom = new Gtk.HBox(false, 0);
		vbox.pack_start(hboxbottom, false, false, 0);
		search = new Gtk.Button.with_label("Search");
		hboxbottom.pack_start(search, false, false, 0);
		
		owonmanager = new OwonManager();

		get_connected();
	}
}

public int main(string [] args) {
	Gtk.init(ref args);
	DBusConnection conn = Bus.get_sync(BusType.SYSTEM);
	
	register_profile(conn, OwonDevice.uuid);

	OwonDisplay owon = new OwonDisplay();
	MainLoop ml = new MainLoop();
	owon.delete_event.connect( () => {
			ml.quit();
			return true;
		});
	owon.show_all();
	ml.run();
	return 0;
}