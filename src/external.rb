require_relative('stdout_log')

class External

  def initialize(options = {})
    @log  = options['log' ] || StdoutLog.new
  end

  attr_reader :log

end
