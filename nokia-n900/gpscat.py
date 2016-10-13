#!/usr/bin/env python2.5

# Nokia N900 / Maemo5: prints GPS records on stdout

# http://wiki.maemo.org/PyMaemo/Using_Location_API

import location
import gobject
import sys
 
def on_error(control, error, data):
    if error == location.ERROR_USER_REJECTED_DIALOG:
        print "!--User didn't enable requested methods"
    elif error == location.ERROR_USER_REJECTED_SETTINGS:
        print "!--User changed settings, which disabled location"
    elif error == location.ERROR_BT_GPS_NOT_AVAILABLE:
        print "!--Bluetooth GPS not available"
    elif error == location.ERROR_METHOD_NOT_ALLOWED_IN_OFFLINE_MODE:
        print "!--Requested method is not allowed in offline mode"
    elif error == location.ERROR_SYSTEM:
        print "!--System error"
    print "!--Location error: %d... quitting" % error
    data.quit()

 
def on_changed(device, data):
    if not device:
        return
    if device.fix:
        if device.fix[1] & location.GPS_DEVICE_LATLONG_SET:
            sys.stdout.write('%f\t' % device.fix[4])
            sys.stdout.write('%f\t' % device.fix[5])
            if device.fix[1] & location.GPS_DEVICE_ALTITUDE_SET:
                sys.stdout.write('%5.0f' % (device.fix[7]/100))
            sys.stdout.write('\t')
            if device.fix[1] & location.GPS_DEVICE_SPEED_SET:
                sys.stdout.write('%6.1f' % (device.fix[11]))
            sys.stdout.write('\t')
            if device.fix[1] & location.GPS_DEVICE_TRACK_SET:
                sys.stdout.write('%d' % (device.fix[9]))
            sys.stdout.write('\t')
            sys.stdout.write('%d\t' % device.satellites_in_use)
            sys.stdout.write('%d\t' % device.satellites_in_view)
            if device.fix[1] & location.GPS_DEVICE_TIME_SET:
                sys.stdout.write('%d' % (device.fix[2]))
            print '\t'
 
def on_stop(control, data):
    print "!--got a 'STOP': quitting"
    data.quit()
 
def start_location(data):
    data.start()
    return False
 
loop = gobject.MainLoop()
control = location.GPSDControl.get_default()
device = location.GPSDevice()
control.set_properties(preferred_method=location.METHOD_USER_SELECTED,
                       preferred_interval=location.INTERVAL_DEFAULT)
 
control.connect("error-verbose", on_error, loop)
device.connect("changed", on_changed, control)
control.connect("gpsd-stopped", on_stop, loop)
 
gobject.idle_add(start_location, control)
 
loop.run()
