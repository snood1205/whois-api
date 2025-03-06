# frozen_string_literal: true

require 'spec_helper'

RSpec.describe App do
  let(:api_key) { create(:api_key) }
  let(:domain) { create(:domain) }

  describe 'GET /get-info' do
    context 'when the request is valid' do
      before { get '/get-info', { domain: domain.domain, api_key: api_key.api_key } }

      it { expect(last_response.status).to eq 200 }
      it { expect(JSON.parse(last_response.body)['creation_date']).to eq domain.creation_date }
      it { expect(JSON.parse(last_response.body)['expiration_date']).to eq domain.expiration_date }
    end
  end
end
