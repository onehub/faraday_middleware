# frozen_string_literal: true

RSpec.describe FaradayMiddleware::MultipartRelated do
  let(:connection) do
    Faraday.new do |b|
      b.request :multipart_related
      b.request :url_encoded
      b.adapter :test do |stub|
        stub.post('/echo') do |env|
          posted_as = env[:request_headers]['Content-Type']
          [200, {'Content-Type' => posted_as}, env[:body]]
        end
      end
    end
  end

  def perform
    body = StringIO.new('{"title":"multipart_related_spec.rb"}')
    metadata = Faraday::UploadIO.new(body, 'application/json')

    file = Faraday::UploadIO.new(__FILE__, 'text/x-ruby')
    connection.post('/echo', [metadata, file])
  end

  it 'sets the Content-Type to multipart/related with the boundary' do
    expected_content_type = "multipart/related;boundary=#{Faraday::Request::Multipart::DEFAULT_BOUNDARY_PREFIX}"

    response = perform
    expect(response.headers['Content-Type']).to eq(expected_content_type)
  end

  it 'sets the body to a Faraday::CompositeReadIO' do
    response = perform
    expect(response.body).to be_an_instance_of(Faraday::CompositeReadIO)
  end
end
