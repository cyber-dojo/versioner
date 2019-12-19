
module DotEnv

  def dot_env(name)
    entry = raw_dot_env[name]
    refute entry.nil?, "#{name}: no entry"
    refute entry.empty?, "#{name}: empty entry"
    entry
  end

  def raw_dot_env
    @dot_env ||= begin
      lines = IO.read('/app/.env').lines
      lines.reject! { |line| line.strip.empty? }
      lines.map { |line| line.strip.split('=',2) }.to_h
    end
  end

end
