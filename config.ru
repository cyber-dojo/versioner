$stdout.sync = true
$stderr.sync = true

require_relative './src/external'
require_relative './src/versioner'
require_relative './src/rack_dispatcher'
require 'rack'

use Rack::Deflater, if: ->(_, _, _, body) { body.any? && body[0].length > 512 }

external = External.new
versioner = Versioner.new(external)
run RackDispatcher.new(versioner)
