require 'rack'
require_relative './src/external'
require_relative './src/versioner'
require_relative './src/rack_dispatcher'

use Rack::Deflater, if: ->(_, _, _, body) { body.any? && body[0].length > 512 }

versioner = Versioner.new(External.new)
run RackDispatcher.new(versioner)
