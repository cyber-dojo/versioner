
class Versioner

  def initialize(_external)
  end

  def sha
    ENV['SHA']
  end

  def ready?
    true
  end

  def dot_env
    src = IO.read('/app/.env')
    lines = src.lines.reject do |line|
      line.start_with?('#') || line.strip.empty?
    end
    lines.map { |line| line.split('=').map(&:strip) }.to_h
  end

end
