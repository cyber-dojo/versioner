#!/usr/bin/ruby

require_relative 'json_files'
require 'minitest/autorun'

class JsonFilesTest < Minitest::Test

  def test_tag_digest_match_in_image
    services.each do |name|
      j = json_for(name)
      assert j['image'].end_with?(":#{j['tag']}@sha256:#{j['digest']}"), j
    end
  end

  private

  include JsonFiles

end
