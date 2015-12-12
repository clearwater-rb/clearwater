require 'clearwater/browser/http/response'
require 'native'

module Clearwater
  module Browser
    module HTTP
      describe Response do
        let(:xhr) {
          {
            status: 200,
            response: '{"foo":"bar"}',
          }
        }
        let(:response) { Response.new(xhr.to_n) }

        it 'is successful with a status code of 2xx' do
          expect(response).to be_success
        end

        it 'is successful with a status code of 3xx' do
          xhr[:status] = 300
          expect(response).to be_success
        end

        it 'fails with a status code of 4xx' do
          xhr[:status] = 400
          expect(response).to be_fail
        end

        it 'fails with a status code of 5xx' do
          xhr[:status] = 500
          expect(response).to be_fail
        end

        it 'parses JSON' do
          expect(response.json).to eq({ foo: 'bar' })
        end
      end
    end
  end
end
