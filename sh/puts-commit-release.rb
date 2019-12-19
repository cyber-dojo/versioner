#!/usr/bin/ruby

# "[RELEASE=1.2.3] blah blah"  => '1.2.3'
# "blah blah blah" => ''

git_commit_msg = ENV['GIT_COMMIT_MSG']
match = git_commit_msg.match(/^\[RELEASE=(\d+\.\d+\.\d+)\].*/)
if match
  puts match[1]
end
