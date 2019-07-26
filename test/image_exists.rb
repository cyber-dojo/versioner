
module ImageExists

  def image_exists?(name)
    `DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect #{name} 2> /dev/null`
    $?.exitstatus === 0
  end

end
