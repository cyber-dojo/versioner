
module ImageName

  def image_name(env_name)
    sha = dot_env(env_name)
    name = env_name.split('_')[2].downcase
    sha7 = sha[0...7]
    "cyberdojo/#{name}:#{sha7}"
  end

end
