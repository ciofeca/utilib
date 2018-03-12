#!/usr/bin/env ruby

# a postgresql notify event will trigger action in this ruby script
# (a notify event may include a payload string)

require 'pg'

channel = 'ruby'
seconds = 0.5

db = PG::Connection.new
db.exec "listen #{channel}"

if ARGV.first == '--test'
  db.exec "notify #{channel}, 'test ok'"
end

while true
  db.wait_for_notify(seconds) do |channel, processid, payload|
    puts "!--notify incoming at #{Time.now} -- payload string: #{payload.inspect}"
  end
end
