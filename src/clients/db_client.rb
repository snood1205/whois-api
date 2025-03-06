# frozen_string_literal: true

# Extned the PG::Connection class to add debug_puts method
class DbClient < PG::Connection
  def initialize(*args)
    super
  end

  def exec(query)
    debug_puts "Executing query: #{query}"
    super
  end

  def exec_params(query, params)
    debug_puts "Executing query: #{query} with params: #{params.map(&:to_s)}"
    super
  end

  private

  def debug_puts(info)
    puts "[#{Time.now}] #{info}" if ENV['DEBUG']
  end

  # A custom error class for non-unique key-value pairs
  class NonUniqueKVError < StandardError
    attr_reader :key, :value

    def initialize(key, value)
      message = "Non-unique KV Error: Unique key #{key} already has entry for value #{value}."
      super(message)

      @domain = domain
      @expiration_date = expiration_date
    end
  end
end
