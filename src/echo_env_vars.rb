
# Use:
#
# $ docker run --rm cyberdojo/versioner:latest ruby /app/src/echo_env_vars.rb > /tmp/.env
# $ set -a
# $ . /tmp/.env
# $ set +a
#
# This will set env-vars, such as
# CYBER_DOJO_RUNNER_SHA=df2157263cad705c69a3fafe77ce4b78f54301ca
# CYBER_DOJO_RUNNER_TAG=df21572

DOT_ENV = begin
  src = IO.read('/app/.env')
  lines = src.lines.reject do |line|
    line.start_with?('#') || line.strip.empty?
  end
  lines.map { |line| line.split('=').map(&:strip) }.to_h
end

def tag_name(key)
  parts = key.split('_')[0..-2] << 'TAG'
  parts.join('_')
end

def tag_value(sha)
  sha[0...7]
end

def dont_tag?(key)
  %w(
    CYBER_DOJO_PORT
    CYBER_DOJO_CUSTOM
    CYBER_DOJO_EXERCISES
    CYBER_DOJO_LANGUAGES
  ).include?(key)
end

# - - - - - - - - - - - - - - - - - - - - - - - -

DOT_ENV.each do |key,value|
  puts "#{key}=#{value}"
end

DOT_ENV.each do |key,value|
  unless dont_tag?(key)
    puts "#{tag_name(key)}=#{tag_value(value)}"
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - -
# Notes: I would like to be able to use versioner's .env file as follows
#
# $ docker run --rm cyberdojo/versioner:latest sh -c 'cat /app/.env' > /tmp/.env
# $ set -a
# $ . /tmp/.env
# $ set +a
#
# this would give, eg
# CYBER_DOJO_RUNNER_SHA=df2157263cad705c69a3fafe77ce4b78f54301ca
#
# and then in the docker-compose.yml file I would get the image tag from the sha.
#
# services:
#   runner:
#     image: cyberdojo/runner:${CYBER_DOJO_RUNNER_SHA:0:7}
#
# However, you cant use that :0:7 bashism inside a docker-compose yaml file :-(
# So instead, there is this script, which generates the extra env vars.
# It is used in commander in cmd/lib/dot_env.rb
