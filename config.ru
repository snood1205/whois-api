# frozen_string_literal: true

require './src/app'
require 'rack'
require 'logger'

use Rack::CommonLogger, Logger.new('./request_debug.log')

run App
