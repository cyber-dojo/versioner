#!/usr/bin/ruby

require_relative 'dot_env'
require 'minitest/autorun'

class StartPointEntriesTest < Minitest::Test

  def test_all_start_points_were_created_from_named_start_points_base
    # If we have updated only CYBER_DOJO_START_POINTS_BASE_SHA
    # with the intention of building new local versions of
    # custom/exercises/languages
    # then the base-sha will not match.
    # So these tests WARN when there isn't a match.
    base_sha = dot_env('CYBER_DOJO_START_POINTS_BASE_SHA')

    image_name = cel_image_name('CUSTOM')
    custom_base_sha = `docker run --rm #{image_name} sh -c 'printf ${BASE_SHA}'`
    if base_sha != custom_base_sha
      puts 'WARNING: Out of date base-image'
      puts "BASE_SHA=#{base_sha} #{base_image_name}"
      puts "BASE_SHA=#{custom_base_sha} #{image_name}"
    end

    image_name = cel_image_name('EXERCISES')
    exercises_base_sha = `docker run --rm #{image_name} sh -c 'printf ${BASE_SHA}'`
    if base_sha != exercises_base_sha
      puts 'WARNING: Out of date base-image'
      puts "BASE_SHA=#{base_sha} #{base_image_name}"
      puts "BASE_SHA=#{exercises_base_sha} #{image_name}"
    end

    image_name = cel_image_name('LANGUAGES')
    languages_base_sha = `docker run --rm #{image_name} sh -c 'printf ${BASE_SHA}'`
    if base_sha != languages_base_sha
      puts 'WARNING: Out of date base-image'
      puts "BASE_SHA=#{base_sha} #{base_image_name}"
      puts "BASE_SHA=#{languages_base_sha} #{image_name}"
    end
  end

  private

  include DotEnv

  def base_image_name
    image_name = dot_env('CYBER_DOJO_START_POINTS_BASE_IMAGE')
    image_tag = dot_env('CYBER_DOJO_START_POINTS_BASE_TAG')
    "#{image_name}:#{image_tag}"
  end

  def cel_image_name(cel)
    image_name = dot_env("CYBER_DOJO_#{cel}_START_POINTS_IMAGE")
    image_tag = dot_env("CYBER_DOJO_#{cel}_START_POINTS_TAG")
    "#{image_name}:#{image_tag}"
  end

end
