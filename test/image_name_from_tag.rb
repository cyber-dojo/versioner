
module ImageNameFromTag

  def image_name_from_tag(tag_env_name) # eg CYBER_DOJO_AVATARS_TAG
    tag = dot_env(tag_env_name)
    parts = tag_env_name.split('_').map(&:downcase)
    # remove cyber-dojo (2) from start
    # remove tag (1) from end
    name = parts[2..-2].join('-')
    if name === 'languages-start-points'
      "cyberdojo/#{name}-common:#{tag}"
    else
      "cyberdojo/#{name}:#{tag}"
    end
  end

end
