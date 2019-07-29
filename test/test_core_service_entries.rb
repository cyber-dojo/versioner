#!/usr/bin/ruby

require_relative 'dot_env'
require_relative 'image_exists'
require_relative 'image_name'
require 'minitest/autorun'

class CoreServicesEntriesTest < MiniTest::Test

  def test_env_file_has_valid_core_service_entries
    vars = env_vars.dup
    vars.delete('CYBER_DOJO_PORT')
    vars.delete('CYBER_DOJO_CUSTOM')
    vars.delete('CYBER_DOJO_EXERCISES')
    vars.delete('CYBER_DOJO_LANGUAGES')
    vars.delete('CYBER_DOJO_STARTER_BASE_SHA')
    vars.delete('CYBER_DOJO_STARTER_BASE_TAG')
    tags = vars.keys.select{ |name| name.end_with?('TAG') }
    tags.sort.each do |tag_env_name|
      tag_value = vars[tag_env_name]
      name = image_name(tag_env_name)
      assert image_exists?(name), "#{tag_env_name}=#{tag_value} #{name} does not exist"
    end
  end

  def test_sha_looks_like_a_SHA
    sha_names.sort.each do |sha_env_name|
      sha = dot_env(sha_env_name)
      assert_equal 40, sha.size
      sha.each_char do |ch|
        assert sha_char?(ch), "sha:#{ch} is not a SHA character"
      end
    end
  end

  def test_tag_looks_like_a_TAG
    tag_names.sort.each do |tag_env_name|
      tag = dot_env(tag_env_name)
      assert_equal 7, tag.size
      tag.each_char do |ch|
        assert sha_char?(ch), "tag:#{ch} is not a SHA character"
      end
    end
  end

  def test_tag_is_first_seven_chars_of_sha
    tag_names.sort.each do |tag_env_name|
      tag = dot_env(tag_env_name)
      sha_env_name = tag_env_name.sub('TAG', 'SHA')
      sha = dot_env(sha_env_name)
      assert sha.start_with?(tag)
    end
  end

  private

  def tag_names
    env_vars.keys.select{ |name| name.end_with?('TAG') }
  end

  def sha_names
    env_vars.keys.select{ |name| name.end_with?('SHA') }
  end

  def sha_char?(ch)
    '0123456789abcdef'.include?(ch)
  end

  def env_vars
    @env_vars ||= raw_dot_env
  end

  include DotEnv
  include ImageExists
  include ImageName

end
