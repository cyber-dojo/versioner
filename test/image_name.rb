
module ImageName

  def image_name(tag_env_name) # eg CYBER_DOJO_AVATARS_TAG
    tag = dot_env(tag_env_name)
    parts = tag_env_name.split('_').map(&:downcase)
    name = parts[2..-2].join('-')
    if name === 'languages-start-points'
      "cyberdojo/#{name}-common:#{tag}"
    else
      "cyberdojo/#{name}:#{tag}"
    end
  end

end
