require 'json'

module JsonFiles

  def services
    %w(
          custom-start-points
          exercises-start-points
          languages-start-points
          creator
          dashboard
          differ
          nginx
          runner
          saver
          web
    )
  end

  def json_for(service)
    JSON.parse(IO.read("/app/json/#{service}.json"))
  end

end
