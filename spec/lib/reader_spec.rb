# frozen_string_literal: true

RSpec.describe GemfileReader::Reader do
  let(:gemfile_path) { fixture_path("Gemfile") }
  let(:reader) { described_class.new(gemfile_path) }
  let(:gem_name) { "rails" }

  describe "#call " do
    context "when a gem is installed locally" do
      let(:description) { "Local gem description" }

      before do
        gem_spec = instance_double(Gem::Specification, description: description)
        allow(Gem::Specification).to receive(:find_by_name).with(gem_name).and_return(gem_spec)
      end

      it "returns the description from local gem spec" do
        expect(reader.call).to eq([{ "rails" => description }])
      end
    end

    context "when local_description does not exist" do
      let(:api_response) { File.read(fixture_path("rails.json")) }

      before do
        stub_request(:get, "https://rubygems.org/api/v1/gems/#{gem_name}.json")
          .to_return(body: api_response, headers: { "Content-Type" => "application/json" })
      end

      it "returns the description from the API" do
        expect(reader.call).to eq([{ "rails" => "API gem description" }])
      end
    end
  end
end
