#!/usr/bin/ruby

require_relative 'dot_env'
require_relative 'image_exists'
require 'minitest/autorun'

class CoreServicesEntriesTest < Minitest::Test

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

  def image_name_from_tag(tag_env_name)            # eg CYBER_DOJO_AVATARS_TAG
    image_env_name = tag_env_name[0..-4] + 'IMAGE' # eg CYBER_DOJO_AVATARS_IMAGE
    image = dot_env(image_env_name) # eg cyberdojo/avatars
    tag = dot_env(tag_env_name)     # eg 392e707
    "#{image}:#{tag}" # eg cyberdojo/avatars:392e707
  end

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

end
