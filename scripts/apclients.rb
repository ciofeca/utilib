#!/usr/bin/env ruby

# show the clients connected to the access point wifi interface, and their IP address and upload/download traffic
# the interface is configured as "Mode: Hotspot" in the NetworkManager, thus uses dnsmasq

AP=ARGV.first || 'wlan1'


class String
  def mb
    ((to_i / 100000) / 10.0).to_s + " Mb"
  end

  def s
    Time.at(to_i / 1000).strftime '%T'
  end
end


# first: fetch the leases, IP address by MAC address
#
leases = {}
leases.default = [ '', '', '?' ]
open('/var/lib/misc/dnsmasq.leases').readlines.each do |lea|
  info = lea.split
  leases[ info[1] ] = [ Time.at(info.first.to_i).strftime('%a-%T'), info[2], info[3] ]
end


# then: fetch the clients info
#
clist = `iw dev #{AP} station dump`.split /Station /
clist[1..-1].collect! do |sta|
  info = sta.split
  macaddr, inactms, rx, tx = info[0], info[5], info[9], info[15]
  puts "%17s  %13s %-13s %-33s %10s %14s %14s" % ( [ macaddr ] + leases[macaddr] + [ inactms.s, tx.mb, rx.mb ] )
end


