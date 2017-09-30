

void print_measurement(MeasurementResult res)
{
	stdout.printf("measure: %s\n", res.print_value());

}

OwonDevice owondev;


bool try_to_connect() {
	OwonManager manager = new OwonManager();
	try {
		manager.discover();
		owondev = manager.get_known();
		if (owondev != null) {
			owondev.got_measurement.connect(print_measurement);
			owondev.start_measure();
		}
	} catch(IOError e) {
		stderr.printf("error getting owon device: %s\n", e.message);
	}
	return owondev == null;
}

public int main(string [] args) {
	DBusConnection conn = Bus.get_sync(BusType.SYSTEM);

	register_profile(conn, OwonDevice.uuid);
	
	if (try_to_connect()) {
		stderr.printf("no devices connected, waiting\n");
		Timeout.add(2000, try_to_connect);
	}
	
	new MainLoop().run();
	return 0;
}