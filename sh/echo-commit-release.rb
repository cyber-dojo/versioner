#!/usr/bin/ruby

# "[RELEASE=1.2.3] blah blah"  => 1.2.3

commit_msg = ENV['GIT_COMMIT_MSG']
match = commit_msg.match(/^\[RELEASE=(\d+\.\d+\.\d+)\].*/)
puts match[1]
