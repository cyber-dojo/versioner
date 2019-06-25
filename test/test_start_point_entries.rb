#!/usr/bin/ruby

require_relative 'dot_env'
require_relative 'image_exists'
require_relative 'image_name'
require 'minitest/autorun'

class StartPointEntriesTest < MiniTest::Test

  def test_env_file_has_valid_start_points
    custom = dot_env('CYBER_DOJO_CUSTOM')
    exercises = dot_env('CYBER_DOJO_EXERCISES')
    languages = dot_env('CYBER_DOJO_LANGUAGES')
    assert image_exists?(custom), "CYBER_DOJO_CUSTOM: #{custom} does not exist"
    assert image_exists?(exercises), "CYBER_DOJO_EXERCISES: #{exercises} does not exist"
    assert image_exists?(languages), "CYBER_DOJO_LANGUAGES: #{languages} does not exist"
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def test_starter_base_image_exists
    var = 'CYBER_DOJO_STARTER_BASE_SHA'
    sha = dot_env(var)
    sha7 = sha[0...7]
    name = "cyberdojo/starter-base:#{sha7}"
    assert image_exists?(name), "#{var}=#{sha} #{name} does not exist"
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def test_all_start_points_were_created_from_named_starter_base
    # If we have updated only CYBER_DOJO_STARTER_BASE_SHA
    # with the intention of building new local versions of
    # custom/exercises/languages
    # then the base-sha will not match.
    # So these tests WARN when there isn't a match.
    sha = dot_env('CYBER_DOJO_STARTER_BASE_SHA')

    image = dot_env('CYBER_DOJO_CUSTOM')
    base_sha = `docker run --rm #{image} sh -c 'echo -n ${BASE_SHA}'`
    diagnostic = "CYBER_DOJO_CUSTOM's BASE_SHA env-var does not match CYBER_DOJO_STARTER_BASE_SHA"
    if sha != base_sha
      echo "WARNING: #{diagnostic}"
    end

    image = dot_env('CYBER_DOJO_EXERCISES')
    base_sha = `docker run --rm #{image} sh -c 'echo -n ${BASE_SHA}'`
    diagnostic = "CYBER_DOJO_EXERCISES's BASE_SHA env-var does not match CYBER_DOJO_STARTER_BASE_SHA"
    if sha != base_sha
      echo "WARNING: #{diagnostic}"
    end

    image = dot_env('CYBER_DOJO_LANGUAGES')
    base_sha = `docker run --rm #{image} sh -c 'echo -n ${BASE_SHA}'`
    diagnostic = "CYBER_DOJO_LANGUAGES's BASE_SHA env-var does not match CYBER_DOJO_STARTER_BASE_SHA"
    if sha != base_sha
      echo "WARNING: #{diagnostic}"
    end
  end

  private

  include DotEnv
  include ImageExists
  include ImageName

end
