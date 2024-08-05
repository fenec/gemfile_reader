# frozen_string_literal: true

RSpec.describe GemfileReader::Reader do
  let(:gemfile_path) { fixture_path("Gemfile") }
  let(:reader) { described_class.new(gemfile_path) }
  let(:gem_name) { "rails" }

  before do
    # Suppress puts in specs stdout
    allow($stdout).to receive(:write)
  end

  shared_examples "gem description output" do |local_gems:, missing_gems:|
    let(:expected_output) do
      <<~STRING
        "Local gems:"
        #{local_gems}
        "Missing gems:"
        #{missing_gems}
      STRING
    end

    it "returns the correct gem description" do
      expect { reader.call }.to output(expected_output).to_stdout
    end
  end

  describe "#call" do
    context "when a gem is installed locally" do
      let(:description) { "Local gem description" }
      let(:gem_spec) { instance_double(Gem::Specification, description: description) }

      before do
        allow(Gem::Specification).to receive(:find_by_name).with(gem_name).and_return(gem_spec)
      end

      include_examples "gem description output",
                       local_gems: "[{\"rails\"=>\"Local gem description\"}]",
                       missing_gems: "[]"
    end

    context "when a gem is not installed locally" do
      let(:api_response) { File.read(fixture_path("rails.json")) }

      before do
        stub_request(:get, "https://rubygems.org/api/v1/gems/#{gem_name}.json")
          .to_return(body: api_response, headers: { "Content-Type" => "application/json" })
      end

      include_examples "gem description output",
                       local_gems: "[]",
                       missing_gems: "[{\"rails\"=>\"API gem description\"}]"
    end
  end
end
