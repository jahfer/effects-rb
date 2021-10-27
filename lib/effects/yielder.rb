# frozen_string_literal: true

module Effects
  class Yielder
    def initialize(yield_points)
      self.valid_yield_points = yield_points
      self.expired_yield_points = []
    end

    def yield(current_yield_point, *args)
      return unless current_yield_point == requested_yield_point
      validate(current_yield_point)
      yield_point_or_err = Fiber.yield(*args)
      yield_at_point(yield_point_or_err)
    end

    def yield_at_point(yield_point_or_err)
      if yield_point_or_err.respond_to?(:exception)
        raise yield_point_or_err.exception
      end
      validate(yield_point_or_err)
      self.requested_yield_point = yield_point_or_err
      invalidate_yield_points
    end

    private

    attr_accessor :valid_yield_points, :requested_yield_point, :expired_yield_points

    def validate(point)
      return true if point.nil?
      return true if valid_yield_points.include?(point)

      message = if expired_yield_points.include?(point)
                  "Requested yield point #{point.inspect} has already passed"
                else
                  "#{point.inspect} is not a valid yield point. Must be one of: #{valid_yield_points.map(&:inspect).join(', ')}."
                end
      raise(InvalidYieldPoint, message)
    end

    def invalidate_yield_points
      points_to_invalidate = valid_yield_points.take_while do |point|
        point != requested_yield_point
      end
      self.valid_yield_points = valid_yield_points - points_to_invalidate
      expired_yield_points.concat(points_to_invalidate)
    end
  end
  private_constant :Yielder
end
