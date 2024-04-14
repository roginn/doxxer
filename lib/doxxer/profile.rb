# frozen_string_literal: true

# require 'debug_inspector'

module Doxxer
  class Profile

    attr_accessor :calls_count, :calls, :allowed_classes

    def initialize
      @calls = Hash.new { |hash, key| hash[key] = Set.new }
      @calls_count = 0
      @allowed_classes = []
      @allowed_paths = []

      # reverse_singleton[klass.singleton_class] = klass
      @reverse_singleton = {}
    end

    def include_path(path)
      @allowed_paths << path
    end

    def include(klass)
      # add_to_sorted_array @allowed_classes, serialize_class(klass)
      @allowed_classes << serialize_class(klass)
      @reverse_singleton[klass.singleton_class] = klass
    end


    def allowed?(klass)
      # candidates = [tp.self, tp.self.class, tp.defined_class].select { |c| c.is_a?(Class) }
      # candidates.any? do |candidate|
      #   allowed_class?(candidate) || allowed_path?(candidate)
      # end
      allowed_class?(klass) || allowed_path?(klass)
    end

    def allowed_class?(klass)
      lookup_class = klass.singleton_class? ? @reverse_singleton[klass] : klass
      @allowed_classes.include? serialize_class(lookup_class)
      # a = @allowed_classes.bsearch { |allowed_class| serialize_class(klass) <=> allowed_class }
      # if a
      #   puts "ALLOWED CLASS: #{klass.name}"
      # end
      # a
    end

    def allowed_path?(klass)
      # TO DO: adicionar cache
      return false unless klass.name
      begin
        path = Module.const_source_location(klass.name).first
      rescue NameError => e
        return false
      end
      a = @allowed_paths.any? { |allowed_path| path.include?(allowed_path) }
      if a
        # puts "ALLOWED PATH: #{klass.name}"
      end
      a
    end

    def register_call(caller_class, called_class)
      @calls[caller_class] << called_class
      increment_calls_count
    end

    def normalize_singleton(klass)
      klass.singleton_class? ? @reverse_singleton[klass] : klass
    end

    private

    def serialize_class(klass)
      "#{klass.name}/#{klass.object_id}"
    end

    def increment_calls_count
      @calls_count += 1
    end
  end
end
