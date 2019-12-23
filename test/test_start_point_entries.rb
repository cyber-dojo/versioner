#!/usr/bin/ruby

require_relative 'dot_env'
require_relative 'image_exists'
require_relative 'image_name'
require 'minitest/autorun'

class StartPointEntriesTest < MiniTest::Test

  def test_env_file_has_valid_start_points
    custom = dot_env('CYBER_DOJO_CUSTOM_START_POINTS')
    exercises = dot_env('CYBER_DOJO_EXERCISES_START_POINTS')
    languages = dot_env('CYBER_DOJO_LANGUAGES_START_POINTS')
    assert image_exists?(custom), "CYBER_DOJO_CUSTOM_START_POINTS: #{custom} does not exist"
    assert image_exists?(exercises), "CYBER_DOJO_EXERCISES_START_POINTS: #{exercises} does not exist"
    assert image_exists?(languages), "CYBER_DOJO_LANGUAGES_START_POINTS: #{languages} does not exist"
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def test_start_points_base_image_exists
    var = 'CYBER_DOJO_START_POINTS_BASE_SHA'
    sha = dot_env(var)
    sha7 = sha[0...7]
    name = "cyberdojo/start-points-base:#{sha7}"
    assert image_exists?(name), "#{var}=#{sha} #{name} does not exist"
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def test_all_start_points_were_created_from_named_start_points_base
    # If we have updated only CYBER_DOJO_START_POINTS_BASE_SHA
    # with the intention of building new local versions of
    # custom/exercises/languages
    # then the base-sha will not match.
    # So these tests WARN when there isn't a match.
    sha = dot_env('CYBER_DOJO_START_POINTS_BASE_SHA')

    image = dot_env('CYBER_DOJO_CUSTOM_START_POINTS')
    base_sha = `docker run --rm #{image} sh -c 'echo -n ${BASE_SHA}'`
    diagnostic = "CYBER_DOJO_CUSTOM_START_POINTS's BASE_SHA env-var does not match CYBER_DOJO_START_POINTS_BASE_SHA"
    if sha != base_sha
      puts "WARNING: #{diagnostic}"
    end

    image = dot_env('CYBER_DOJO_EXERCISES_START_POINTS')
    base_sha = `docker run --rm #{image} sh -c 'echo -n ${BASE_SHA}'`
    diagnostic = "CYBER_DOJO_EXERCISES_START_POINTS's BASE_SHA env-var does not match CYBER_DOJO_START_POINTS_BASE_SHA"
    if sha != base_sha
      puts "WARNING: #{diagnostic}"
    end

    image = dot_env('CYBER_DOJO_LANGUAGES_START_POINTS')
    base_sha = `docker run --rm #{image} sh -c 'echo -n ${BASE_SHA}'`
    diagnostic = "CYBER_DOJO_LANGUAGES_START_POINTS's BASE_SHA env-var does not match CYBER_DOJO_START_POINTS_BASE_SHA"
    if sha != base_sha
      puts "WARNING: #{diagnostic}"
    end
  end

  private

  include DotEnv
  include ImageExists
  include ImageName

end
