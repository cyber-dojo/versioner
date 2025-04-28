#!/usr/bin/ruby

require_relative 'json_files'
require 'minitest/autorun'

class JsonDigestsTest < Minitest::Test

  def test_digest_matches_image_suffix
    services.each do |name|
      j = json_for(name)
      j_tag = j['tag']
      image = "cyberdojo/#{name}:#{j_tag}"
      j_digest = j['digest']
      `docker pull #{image}`
      full_digest = `docker inspect --format='{{index .RepoDigests 0}}' "#{image}"`
      d_digest = full_digest.rstrip[-64..-1]
      diagnostic = "DIGESTS NOT THE SAME:\n  j_digest=:#{j_digest}:\n  d_digest=:#{d_digest}:"
      assert d_digest == j_digest, diagnostic
      printf '.'
    end
  end

  private

  include JsonFiles

end
