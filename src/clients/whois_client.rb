# frozen_string_literal: true

require_relative '../services/whois_service'

# A client for fetching WHOIS information about a domain.
class WhoisClient
  INSERT_STATEMENT = <<~SQL
    INSERT INTO domains (domain, creation_date, expiration_date)
    VALUES ($1, $2, $3)
    ON CONFLICT DO NOTHING
  SQL

  def initialize(db_client)
    @db_client = db_client
  end

  def whois_info(domain)
    result = @db_client.exec_params 'SELECT * FROM domains WHERE domain = $1', [domain]
    return handle_found_record(result.first, domain) unless result.ntuples.zero?

    fetch_from_server(domain) => { creation_date:, expiration_date: }
    insert_record!(domain, creation_date, expiration_date)
  end

  private

  def fetch_from_server(domain)
    WhoisService.fetch(domain) => { creation_date:, expiration_date: }
    raise BadDomainError if creation_date.nil? || expiration_date.nil?
    raise ExpiredDomainError.new(domain, expiration_date) if expiration_date < DateTime.now

    { creation_date:, expiration_date: }
  end

  def handle_found_record(record, domain)
    expired = DateTime.parse(record['expiration_date']) < DateTime.now
    return record&.slice('domain', 'creation_date', 'expiration_date')&.transform_keys(&:to_sym) unless expired

    fetch_from_server(domain) => { creation_date:, expiration_date: }
    update_record!(domain, creation_date, expiration_date)
    { domain:, creation_date:, expiration_date: }
  end

  def insert_record!(domain, creation_date, expiration_date)
    @db_client.exec_params INSERT_STATEMENT, [domain, creation_date, expiration_date]

    { domain:, creation_date:, expiration_date: }
  end

  def update_record!(domain, creation_date, expiration_date)
    @db_client.exec_params 'UPDATE domains SET creation_date = $1, expiration_date = $2 WHERE domain = $3',
                           [creation_date, expiration_date, domain]
  end

  class BadDomainError < StandardError; end

  # Error raised when a domain is expired.
  class ExpiredDomainError < StandardError
    attr_reader :domain, :expiration_date

    def initialize(domain, expiration_date)
      message = "Domain #{domain} expired on #{expiration_date}"
      super(message)

      @domain = domain
      @expiration_date = expiration_date
    end
  end
end
