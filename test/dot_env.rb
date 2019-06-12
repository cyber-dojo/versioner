
module DotEnv

  def dot_env(name)
    entry = raw_dot_env[name]
    refute entry.nil?, "#{name}: no entry"
    refute entry.empty?, "#{name}: empty entry"
    entry
  end

  def raw_dot_env
    @dot_env ||= read_dot_env
  end

  def read_dot_env
    lines = IO.read('/app/.env').lines
    lines.reject! do |line|
      line.strip.empty? || line.start_with?('#')
    end
    lines.map { |line| line.strip.split('=',2) }.to_h
  end

end
