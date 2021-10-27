# frozen_string_literal: true

require 'test_helper'

module Effects
  class ProcessTest < ActiveSupport::TestCase
    test "#initialize doesn't run" do
      assert_nothing_raised do
        Effects::Process.new(steps: []) do |y|
          raise "This line is never evaluated"
        end
      end
    end

    test "#run with no block runs to completion" do
      my_boolean = false
      process = Effects::Process.new(steps: [:unused_step]) do |y|
        y.yield(:unused_step)
        my_boolean = true
        "some result"
      end
      result = process.call
      assert my_boolean
      assert_equal "some result", result
    end

    test "#call with argument pauses execution at requested point" do
      counter = 0
      process = Effects::Process.new(steps: [:a, :b]) do |y|
        counter = 1
        y.yield(:a)
        counter = 2
        y.yield(:b)
        raise "This line is never evaluated"
      end
      assert_equal(0, counter)
      process.(:a)
      assert_equal(1, counter)
      process.(:b)
      assert_equal(2, counter)
    end

    test "#call with invalid argument raises" do
      process = Effects::Process.new(steps: [:a, :b]) do |y|
        y.yield(:a)
        y.yield(:b)
      end

      assert_nothing_raised { process.(:a) }

      error = assert_raises(InvalidYieldPoint) do
        process.(:c)
      end
      error_message = ":c is not a valid yield point. Must be one of: :a, :b."
      assert_equal error_message, error.message
    end

    test "#call with expired step raises" do
      process = Effects::Process.new(steps: [:a, :b]) do |y|
        y.yield(:a)
        y.yield(:b)
      end

      assert_nothing_raised { process.(:b) }

      error = assert_raises(InvalidYieldPoint) do
        process.(:a)
      end

      error_message = "Requested yield point :a has already passed"
      assert_equal error_message, error.message
    end

    test "#raise passes exception to process" do
      rescued = false

      process = Effects::Process.new(steps: [:a]) do |y|
        y.yield(:a)
      rescue IOError
        rescued = true
      end

      process.(:a)
      process.raise(IOError)
      assert rescued
    end

    test "#finish runs process to completion" do
      process = Effects::Process.new(steps: [:a, :b]) do |y|
        y.yield(:a)
        y.yield(:b)
        "some result"
      end

      process.(:a)
      result = process.finish
      assert_equal "some result", result
    end

    test "#call with a block will pass exceptions to the process" do
      rescued = false

      process = Effects::Process.new(steps: [:a]) do |y|
        y.yield(:a)
      rescue IOError
        rescued = true
      end

      process.call do
        process.(:a)
        raise IOError
      end
      assert rescued
    end

    test "#call with a block will bubble un-rescued exceptions" do
      process = Effects::Process.new(steps: [:a]) do |y|
        y.yield(:a)
      end

      assert_raises(RuntimeError) do
        process.call do
          raise RuntimeError
        end
      end
    end

    test "#call with arugment returns a value" do
      process = Effects::Process.new(steps: [:a]) do |y|
        y.yield(:a, 42)
        y.yield(:b)
      end

      process_value = process.(:a)
      assert_equal 42, process_value
      assert_nil process.finish
    end

    test "#call with returned data passes by value" do
      process = Effects::Process.new(steps: [:a]) do |y|
        state = { my_boolean: false }
        y.yield(:a, state)
        assert state[:my_boolean]
      end

      state = process.(:a)
      state[:my_boolean] = true
      process.finish
    end

    test "#call with argument and block runs until yield point, yields to block, and completes process" do
      count = 2
      process = Effects::Process.new(steps: [:a]) do |y|
        y.yield(:a)
        count = count + count
      end

      process.(:a) do
        count = count * count
      end

      assert_equal 8, count
    end
  end
end
