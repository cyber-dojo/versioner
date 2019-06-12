#!/usr/bin/ruby

# "[RELEASE=1.2.3] blah blah"  => true

commit_msg = ENV['GIT_COMMIT_MSG']

r = commit_msg.match(/^\[RELEASE=(\d+\.\d+\.\d+)\].*/)
if r.nil?
  exit 1
else
  exit 0
end
