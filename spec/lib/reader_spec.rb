# frozen_string_literal: true

RSpec.describe GemfileReader::Reader do
  let(:gemfile_path) { fixture_path("Gemfile") }
  let(:reader) { described_class.new(gemfile_path) }
  let(:gem_name) { "rails" }

  before do
    # Suppress puts in specs stdout
    allow($stdout).to receive(:write)
  end

  describe "#call"  do
    context "when a gem is installed locally" do
      let(:description) { "Local gem description" }
      let(:gem_spec) { instance_double(Gem::Specification, description: description) }
      let(:expected_output) do
        <<~STRING
          "Local gems:"
          [{"rails"=>"Local gem description"}]
          "Missing gems:"
          []
        STRING
      end

      before do
        allow(Gem::Specification).to receive(:find_by_name).with(gem_name).and_return(gem_spec)
      end

      it "returns the local gem description" do
        expect { reader.call }.to output(expected_output).to_stdout
      end
    end

    context "when a gem is not installed locally" do
      let(:api_response) { File.read(fixture_path("rails.json")) }
      let(:expected_output) do
        <<~STRING
          "Local gems:"
          []
          "Missing gems:"
          [{"rails"=>"API gem description"}]
        STRING
      end

      before do
        stub_request(:get, "https://rubygems.org/api/v1/gems/#{gem_name}.json")
          .to_return(body: api_response, headers: { "Content-Type" => "application/json" })
      end

      it "returns the description from the API" do
        expect { reader.call }.to output(expected_output).to_stdout
      end
    end
  end
end
