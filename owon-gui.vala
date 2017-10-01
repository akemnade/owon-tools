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
	Gtk.Label buttonstatuslabel;
	OwonDevice owon_dev;
	OwonManager owon_manager;
	Gtk.Button owon_select;
	Gtk.Button owon_range;
	Gtk.Button owon_hold;
	Gtk.Button owon_delta;
	Gtk.Button owon_hz_duty;
	Gtk.Button owon_maxmin;
	Gtk.Button search;

	void display_measurement(MeasurementResult res) {
		measurementlabel.set_text(res.print_value());
		string [] status = {};
		if (res.autorange)
			status += "AUTO";
		if (res.max)
			status += "MAX";
		if (res.min)
			status += "MIN";
		if (res.hold)
			status += "H";
		if (res.delta)
			status += "delta";
		if (res.beepmode)
			status += "beep";
		if (res.diode)
			status += "diode";
		StringBuilder b = new StringBuilder();
		if (status.length > 0)
			b.assign(status[0]);
		for(int i = 1; i < status.length; i++) {
			b.append_c(' ');
			b.append(status[i]);
			
		}
		buttonstatuslabel.set_text(b.str);
	}
	
	void get_connected() {
		try {
			owon_manager.discover();
			owon_dev = owon_manager.get_known();
			if (owon_dev != null) {
				owon_dev.got_measurement.connect(display_measurement);
				owon_dev.start_measure();
			}
		} catch (IOError e) {
			measurementlabel.set_text("error getting device:\n%s".printf(e.message)); 
		}
	}

	void select_clicked() {
		if (owon_dev != null)
			owon_dev.press_button(OwonDevice.Button.SELECT, 1);
	}

	void range_clicked() {
		if (owon_dev != null)
			owon_dev.press_button(OwonDevice.Button.RANGE, 1);
	}

	void hold_clicked() {
		if (owon_dev != null)
			owon_dev.press_button(OwonDevice.Button.HOLD_LIGHT, 1);
	}

	void delta_clicked() {
		if (owon_dev != null)
			owon_dev.press_button(OwonDevice.Button.DELTA_BT, 1);
	}
	
	void hz_duty_clicked() {
		if (owon_dev != null)
			owon_dev.press_button(OwonDevice.Button.HZ_DUTY, 1);
	}

	void max_min_clicked() {
		if (owon_dev != null)
			owon_dev.press_button(OwonDevice.Button.MAX_MIN, 1);
	}

	void search_and_connect() {
		search.set_sensitive(false);
		owon_manager.search_and_connect((obj, res) => {
				owon_dev = null;
				if (owon_manager.search_and_connect.end(res)) {
					get_connected();
				}
				search.set_sensitive(true);
			});
	}
	
	public OwonDisplay() {
//		base(Gtk.WindowType.TOPLEVEL);
		var vbox = new Gtk.VBox(false, 0);
		var hboxtop = new Gtk.HBox(false, 0);
		base.add(vbox);
		vbox.pack_start(hboxtop, false, true,0);
		owon_select = new Gtk.Button.with_label("Select");
		hboxtop.pack_start(owon_select, true, true, 0);
		owon_select.clicked.connect(select_clicked);

		owon_range = new Gtk.Button.with_label("Range");
		hboxtop.pack_start(owon_range, true, true, 0);
		owon_range.clicked.connect(range_clicked);
		
		owon_hold = new Gtk.Button.with_label("Hold");
		hboxtop.pack_start(owon_hold, true, true, 0);
		owon_hold.clicked.connect(hold_clicked);
		
		owon_delta = new Gtk.Button.with_label("Delta");
		hboxtop.pack_start(owon_delta, true, true, 0);
		owon_delta.clicked.connect(delta_clicked);

		owon_hz_duty = new Gtk.Button.with_label("Hz/Duty");
		hboxtop.pack_start(owon_hz_duty, true, true, 0);
		owon_hz_duty.clicked.connect(hz_duty_clicked);
		
		owon_maxmin = new Gtk.Button.with_label("Max/Min");
		hboxtop.pack_start(owon_maxmin, true, true, 0);
		owon_maxmin.clicked.connect(max_min_clicked);
		
		measurementlabel = new Gtk.Label("not connected");
		vbox.pack_start(measurementlabel, true ,true, 0);
		buttonstatuslabel = new Gtk.Label("");
		vbox.pack_start(buttonstatuslabel, false, true, 0);
		var hboxbottom = new Gtk.HBox(false, 0);
		vbox.pack_start(hboxbottom, false, false, 0);
		search = new Gtk.Button.with_label("Search");
		search.clicked.connect(search_and_connect);

		hboxbottom.pack_start(search, false, false, 0);
		
		owon_manager = new OwonManager();
		
		
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