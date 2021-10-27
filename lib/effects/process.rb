# frozen_string_literal: true

require 'effects/yielder'

module Effects
  class Process
    def initialize(steps:, &blk)
      self.yielder = Yielder.new(steps)
      self.fiber = generate_fiber(&blk)
    end

    def call(yield_at = nil)
      if yield_at
        result = fiber.resume(yield_at)
        return result unless block_given? && fiber.alive?
      end

      begin
        yield(self, *result) if block_given?
        finish if fiber.alive?
      rescue => error
        fiber.resume(error) if fiber.alive?
      end
    end

    def finish
      fiber.resume
    end

    def raise(error)
      Kernel.raise(ArgumentError, error) unless error.respond_to?(:exception)
      fiber.resume(error)
    end

    def alive?
      fiber.alive?
    end

    private
    attr_accessor :yielder, :fiber

    def generate_fiber(&blk)
      Fiber.new do |requested_yield_point|
        yielder.yield_at_point(requested_yield_point)
        blk.call(yielder)
      end
    end
  end
end
