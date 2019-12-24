#!/usr/bin/ruby

require_relative 'dot_env'
require_relative 'image_name'
require 'minitest/autorun'

class StartPointEntriesTest < MiniTest::Test

  def test_all_start_points_were_created_from_named_start_points_base
    # If we have updated only CYBER_DOJO_START_POINTS_BASE_SHA
    # with the intention of building new local versions of
    # custom/exercises/languages
    # then the base-sha will not match.
    # So these tests WARN when there isn't a match.
    sha = dot_env('CYBER_DOJO_START_POINTS_BASE_SHA')

    image = image_name('CYBER_DOJO_CUSTOM_START_POINTS_TAG')
    base_sha = `docker run --rm #{image} sh -c 'echo -n ${BASE_SHA}'`
    diagnostic = "CYBER_DOJO_CUSTOM_START_POINTS's BASE_SHA env-var does not match CYBER_DOJO_START_POINTS_BASE_SHA"
    if sha != base_sha
      puts "WARNING: #{diagnostic}"
    end

    image = image_name('CYBER_DOJO_EXERCISES_START_POINTS_TAG')
    base_sha = `docker run --rm #{image} sh -c 'echo -n ${BASE_SHA}'`
    diagnostic = "CYBER_DOJO_EXERCISES_START_POINTS's BASE_SHA env-var does not match CYBER_DOJO_START_POINTS_BASE_SHA"
    if sha != base_sha
      puts "WARNING: #{diagnostic}"
    end

    image = image_name('CYBER_DOJO_LANGUAGES_START_POINTS_TAG')
    base_sha = `docker run --rm #{image} sh -c 'echo -n ${BASE_SHA}'`
    diagnostic = "CYBER_DOJO_LANGUAGES_START_POINTS's BASE_SHA env-var does not match CYBER_DOJO_START_POINTS_BASE_SHA"
    if sha != base_sha
      puts "WARNING: #{diagnostic}"
    end
  end

  private

  include DotEnv
  include ImageName

end
