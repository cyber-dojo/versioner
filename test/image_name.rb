
module ImageName

  def image_name(tag_env_name)
    tag = dot_env(tag_env_name)
    name = tag_env_name.split('_')[2].downcase
    "cyberdojo/#{name}:#{tag}"
  end

end
