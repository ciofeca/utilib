#!/usr/bin/env ruby

# finds out duplicate files in the current directory and outputs "shellable" commands


require 'fileutils'

candidate, sameasthis = {}, {}

# -- phase 1: for any possible file size, build a list of "same size as this" filenames
Dir["*"].each do |filename|
  next unless File.stat(filename).file?   # skip non regular files
  filesize = File.stat(filename).size

  unless candidate[filesize]              # if new candidate:
    candidate[filesize] = filename        # "we have this file size" for this filename
    sameasthis[candidate[filesize]] = []  # initialize its "same size files" list
    next
  end

  # found a "same sized" file: add to the relevant list
  sameasthis[candidate[filesize]] << filename
end

# -- phase 2: wipe out files with same size but different contents
sameasthis.each do |filename, lst|
  lst.delete_if { |fname| !FileUtils::cmp(filename, fname) }
end

# -- phase 3: forget files whose size is unique (empty list of "same sized")
sameasthis.delete_if { |filename, lst| lst.empty? }

# -- phase 4: output a shellable commented list
sameasthis.each do |filename, lst|
  puts
  puts "# samefile as #{filename}"
  lst.each { |fname| puts "rm -f #{fname.inspect}" }
  puts
end

# --
