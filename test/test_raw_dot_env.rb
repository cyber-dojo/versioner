#!/usr/bin/ruby

require 'minitest/autorun'

class PortEntryTest < Minitest::Test

  def test_dot_env_file_sourceability
    lines = IO.read('/app/.env').lines
    lines.reject! do |line|
      line.strip.empty? || line.start_with?('#')
    end
    lines.each do |line|
      parts = line.split('=')
      assert_equal 2, parts.size, "#{line} not in NAME=VALUE form"
      name = parts[0]
      assert_equal name.strip, name, "#{name} has leading/trailing whitespace"
      value = parts[1]
      assert_equal value.lstrip, value, "#{value} has leading whitespace"
      assert name.match(/^[A-Z_0-9]+$/), "#{name} can contain only A-Z 0-9 and underscore"
      assert value.match(/^[a-z0-9\:\-\/]+$/), "#{value} can contain only a-z 0-9 colon hyphen forwardSlash"
    end
  end

end
