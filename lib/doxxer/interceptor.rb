# frozen_string_literal: true

require 'debug_inspector'
require 'forwardable'

module Doxxer
  class Interceptor

    extend Forwardable

    def_delegators :profile, :allowed?, :register_call, :normalize_singleton

    attr_reader :profile

    def initialize(profile)
      @profile = profile
    end

    def pry = trace.enable { yield }

    # def prepare_classes
    #   ObjectSpace.each_object(Class).select do |klass|
    #     source_location = Module.const_source_location(klass.name).first
    #     next unless source_location

    #     allowed_paths.any? { |path| source_location.include?(path) }
    #   end
    # end

    # private

    # def add_to_sorted_array(sorted_array, element)
    #   index = sorted_array.bsearch_index { |x| x >= element } || sorted_array.length
    #   sorted_array.insert(index, element)
    # end

    def trace
      @trace ||= TracePoint.new(:call, :c_call) do |tp|
        begin
          next unless [tp.self, tp.self.class, tp.defined_class].select { |c| c.is_a?(Class) }.any? { |c| allowed?(c) }

          called_class = tp.self.is_a?(Class) ? tp.self : tp.self.class
          # puts "Allowed: called_class.name"
          puts "method: #{tp.callee_id}"
          caller_class = nil
          ::DebugInspector.open do |dc|
            begin
              # binding.pry
              size = [dc.backtrace_locations.size, 40].min
              (1..size).each do |frame|
                # puts frame
                klass = dc.frame_class(frame)

                if klass.singleton_class?
                  # this will make klass = nil if the original class (not the singleton)
                  # was not allowed
                  klass = normalize_singleton(klass)
                end
                next if klass.nil?

                # puts "\t#{klass.name}"

                if klass != called_class && allowed?(klass)
                  # puts "found caller class: #{klass.name}"
                  caller_class = klass
                  break
                end
              end
            rescue ArgumentError
              puts "\tArgumentError"
            end
          end
          next if caller_class.nil?
          puts [caller_class, called_class, tp.callee_id].to_s

          # puts tp.callee_id
          register_call(caller_class, called_class)
          # @calls[caller_class] << called_class
          # increment_calls_count
        rescue NoMethodError => e
        end
      end
    end
  end
end
