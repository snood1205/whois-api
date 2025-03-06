# frozen_string_literal: true

FactoryBot.define do
  factory :domain do
    domain { 'gitgetgot.dev' }
    creation_date { DateTime.now - 365 }
    expiration_date { creation_date + 730 }
    trait :expired do
      expiration_date { creation_date + 364 }
    end
  end
end
