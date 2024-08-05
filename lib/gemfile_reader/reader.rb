# frozen_string_literal: true

require "async"
require "http"

module GemfileReader
  class Reader
    COMMENT_REGEX = /^\s*#/
    GEM_REGEX = /gem\s*['"]([a-z_-]+)['"]/
    RUBY_GEMS_API_URI = "https://rubygems.org/api/v1/gems"

    attr_reader :gemfile_path, :local_gems, :missing_gems

    def initialize(gemfile_path = "Gemfile")
      @gemfile_path = gemfile_path
      @local_gems = []
      @missing_gems = []
    end

    def call
      Sync do
        gems_list.map do |gem_name|
          Async { fetch_gem_description(gem_name) }
        end.map(&:wait)
      end
      pp "Local gems:"
      pp local_gems
      pp "Missing gems:"
      pp missing_gems
    end

    private

    def gems_list
      File.foreach(gemfile_path).each_with_object([]) do |line, gems|
        next if line.match?(COMMENT_REGEX)

        if (match = line.match(GEM_REGEX))
          gem_name = match[1]
          gems << gem_name
        end
      end
    end

    def fetch_gem_description(gem_name)
      description = local_description(gem_name)
      if description
        local_gems << { gem_name => description.delete("\n") }
      else
        missing_gems << { gem_name => api_description(gem_name) }
      end
    end

    def local_description(gem_name)
      gem_data = Gem::Specification.find_by_name(gem_name)
      gem_data.description
    rescue Gem::MissingSpecError
      nil
    end

    def api_description(gem_name)
      gem_data = HTTP.get("#{RUBY_GEMS_API_URI}/#{gem_name}.json")
      gem_data.parse["info"]
    end
  end
end
