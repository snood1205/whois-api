# frozen_string_literal: true

FactoryBot.define do
  factory :api_key do
    api_key { 'abcdef01-2345-6789-0abc-def012345678' }
    email { 'test@example.com' }
    validation_code { 'ABC123' }
    email_verified { true }
    trait :unverified do
      email_verified { false }
    end
  end
end
