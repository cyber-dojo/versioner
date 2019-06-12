#!/usr/bin/ruby

require_relative 'dot_env'
require_relative 'image_exists'
require_relative 'image_name'
require 'minitest/autorun'

class CoreServicesEntriesTest < MiniTest::Test

  def test_env_file_has_valid_core_service_entries
    vars = raw_dot_env
    vars.delete('CYBER_DOJO_PORT')
    vars.delete('CYBER_DOJO_CUSTOM')
    vars.delete('CYBER_DOJO_EXERCISES')
    vars.delete('CYBER_DOJO_LANGUAGES')
    vars.delete('CYBER_DOJO_STARTER_BASE_SHA')
    vars.keys.sort.each do |env_name|
      name = image_name(env_name)
      assert image_exists?(name), "#{env_name}: #{name} does not exist"
    end
  end

  private

  include DotEnv
  include ImageExists
  include ImageName

end
