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

/*

result format

1-4:value
5=space
6= decimal point pos

7: 08 = AC
   10 = DC
   20 = Auto
   01 = running
   02 = hold
   04 = delta

8: 20 = MAX
   10 = MIN

9: 40 =m
   80 =µ
   20 =k
   10 =M  
   08 =Beep
   04 =Diode
   02 =% 


10: 02 = °C
    04 = F
    08 = Hz
    10 = HFE
    20 = Ohm
    40 = A
    80 = V 

11: 80 = -
    lower bits: bargraph value
*/


public class MeasurementResult : GLib.Object {
	public bool negative;
	public uint8 [] rawdata;
	public int exponent;
	public string value_string;
	public double value_noexp;
	public double value;
	public string unit;
	public bool autorange;
	public bool valid;
	public bool nan;
	public bool max;
	public bool min;
	public bool hold;
	public bool delta;
	public bool diode;
	public bool running;
	public bool beepmode;
	public int bars;
	[CCode (cheader_filename = "math.h", cname = "pow10")]
	static extern double pow10(double y);
	public MeasurementResult(uint8[] data) {
		int i,j;
		rawdata = data;
		if (data.length != 14) {
			valid = false;
			return;
		}
		max = 0 != (data[8] & 0x20);
		min = 0 != (data[8] & 0x10);
		hold = 0 != (data[7] & 0x02);
		delta = 0 != (data[7] & 0x04);
		running = 0 != (data[7] & 0x01);
		negative = data[0] == '-';
		autorange = 0 != (data[7] & 0x20);
		diode = 0 != (data[9] & 0x04);
		beepmode = 0 != (data[9] & 0x08);
		bars = data[11] & 0x3f;
		nan = (data[1] == '?');
		switch(data[9] & 0xf0) {
		case 0x10: exponent = 6; break;
		case 0x20: exponent = 3; break;
		case 0x40: exponent = -3; break;
		case 0x80: exponent = -6; break;
		default: exponent = 0; break;
		}
		uint8[] val = new uint8[7];
		val[0] = negative ? '-' : 0x20;
		int pointpos = 4;
		switch(data[6]) {
		case 0x30: pointpos = 5; break;
		case 0x31: pointpos = 2; break;
		case 0x32: pointpos = 3; break;
		case 0x34: pointpos = 4; break;
		}
		for(i = 1, j = 1; i < 5; i++, j++) {
			if ((!nan) && (j == pointpos)) {
				val[j] = '.';
				j++;
			}
			val[j] = rawdata[i];
		}
		val[j] = 0;
		value_string = (string)val;
		if (nan) {
			value_noexp = double.NAN;
			value = double.NAN;
		} else {
			value_noexp = double.parse(value_string);

			value = value_noexp * pow10(exponent);
		}
		switch(data[10]) {
		case 0x80: unit = "V " + ((0 != (data[7] & 0x8)) ? "AC" : "DC"); break;
		case 0x20: unit = "Ohm"; break;
		case 0x04: unit = "F"; exponent = -9; break;
		case 0x08: unit = "Hz"; break;
		case 0x10: unit = "HFE"; break;
		case 0x02: unit = "°C"; break;
		case 0x40: unit = "A " + ((0 != (data[7] & 0x8)) ? "AC" : "DC"); break;
		case 0x00: if (0 != (data[9] & 0x02)) unit="%"; break;
		}
		valid = true;
		
	}
	public string print_value() {
		string prefix = "";
		switch(exponent) {
		case 3: prefix = "k"; break;
		case 6: prefix = "M"; break;
		case -3: prefix = "m"; break;
		case -6: prefix = "µ"; break;
		case -9: prefix = "n"; break;
		}
		return value_string + " " + prefix + unit;
	}
}