

void print_measurement(MeasurementResult res)
{
	Posix.timeval tv = Posix.timeval();
	tv.get_time_of_day();
	stdout.printf("%ld measure: %s\n", tv.tv_sec, res.print_value());

}

OwonDevice owondev;
bool autoconnect = false;

bool try_to_connect() {
	OwonManager manager = new OwonManager();
	try {
		manager.discover();
		owondev = manager.get_known();
		if (owondev != null) {
			owondev.got_measurement.connect(print_measurement);
			owondev.start_measure();
		} else if (autoconnect) {
			manager.search_and_connect.begin((obj, res) => {
					bool found = manager.search_and_connect.end(res);
					Timeout.add(2000, try_to_connect);
				});
			return false;
		}
	} catch(IOError e) {
		stderr.printf("error getting owon device: %s\n", e.message);
	}
	return owondev == null;
}

public int main(string [] args) {
	DBusConnection conn = Bus.get_sync(BusType.SYSTEM);

	register_profile(conn, OwonDevice.uuid);
	if (args.length > 1) {
		if (args[1] == "--autoconnect") {
			autoconnect = true;
		} else {
			stdout.printf("Usage: %s [--autoconnect]\n", args[0]);
			return 1;
		}
	}
	if (try_to_connect()) {
		stderr.printf("no devices connected, waiting\n");
		Timeout.add(2000, try_to_connect);
	}
	
	new MainLoop().run();
	return 0;
}
