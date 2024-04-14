# frozen_string_literal: true

require_relative "doxxer/version"
require_relative "doxxer/interceptor"
require_relative "doxxer/profile"
require 'forwardable'

module Doxxer
  class << self
    extend Forwardable
    def_delegators :profile, :include, :include_path, :calls_count

    def pry
      Interceptor.new(profile).pry { yield }
    end

    def profile
      @profile ||= Profile.new
    end

    def reset!
      @profile = nil
    end
  end

  # def_delegator :interceptor, :report, :calls
  # def_delegator :interceptor, :include_path, :spy_path

  # class Error < StandardError; end


  # def self.include_path(path)
  #   interceptor.spy_path(path)
  # end
end
