
module ImageName

  def image_name(tag_env_name)
    tag = dot_env(tag_env_name)
    parts = tag_env_name.split('_').map(&:downcase)
    name = parts[2..-2].join('-')
    "cyberdojo/#{name}:#{tag}"
  end

end
