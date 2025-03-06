# frozen_string_literal: true

# Fetches WHOIS information for a given domain
class WhoisService
  attr_reader :creation_date, :expiration_date

  def self.fetch(domain)
    domain = new(domain)
    domain.fetch
    { creation_date: domain.creation_date, expiration_date: domain.expiration_date }
  end

  def fetch
    IO.popen ['whois', @domain], 'r' do |io|
      io.each_line do |line|
        break if @creation_date && @expiration_date

        check_line_for_creation_date!(line)
        check_line_for_expiration_date!(line)
      end
    end
  end

  private

  def initialize(domain)
    @domain = domain
  end

  def check_line_for_creation_date!(line)
    return if @creation_date

    creation_date_str = /Creation Date: ([^\n]+)/.match(line)&.[](1)&.strip
    return if creation_date_str.nil?

    @creation_date = DateTime.parse(creation_date_str)
  end

  def check_line_for_expiration_date!(line)
    return if @expiration_date

    expiration_date_str = /Registry Expiry Date: ([^\n]+)/.match(line)&.[](1)&.strip
    return if expiration_date_str.nil?

    @expiration_date = DateTime.parse(expiration_date_str)
  end
end
