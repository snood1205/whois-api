# frozen_string_literal: true

FactoryBot.define do
  factory :request do
    api_key { association(:api_key) }
    time { DateTime.now }
  end
end
