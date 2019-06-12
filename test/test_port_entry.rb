#!/usr/bin/ruby

require_relative 'dot_env'
require 'minitest/autorun'

class PortEntryTest < MiniTest::Test

  def test_env_file_has_syntactically_valid_port
    port = dot_env('CYBER_DOJO_PORT')
    assert port =~ /^\d+$/, "CYBER_DOJO_PORT: #{port} is not a number"
  end

  private
  
  include DotEnv

end
