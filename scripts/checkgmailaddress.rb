#!/usr/bin/env ruby

# checks if an email address is a valid recipient (true) or unassigned address (false)
# as of https://blog.0day.rocks/abusing-gmail-to-get-previously-unlisted-e-mail-addresses-41544b62b2
#
def checkgmailaddress addr
  r = `curl -v https://mail.google.com/mail/gxlu?email=#{addr}@gmail.com 2>&1`
  r.include? '< Set-Cookie: COMPASS='
end

addr = ARGV.first
fail "usage: #{$0} address (without the '@gmail.com' part)"  if addr == '-h' || addr == '--help' || addr == nil

if addr.gsub(/[a-z0-9\._]/, '') != ''
  puts "invalid characters"
elsif addr.scan(/(\.\.)+/) != []
  puts "consecutive dots not allowed"
elsif addr.scan(/^[a-z0-9]/) == [] || addr.scan(/[a-z0-9]$/) == []
  puts "must start and end with alphanumeric characters"
elsif checkgmailaddress addr
  puts "#{addr}@gmail.com already exists"
else
  puts "#{addr}@gmail.com has not yet been registered by anyone"
  puts "(gmail may not approve an address like this, shorter than 8 characters)" if addr.size < 8
end

