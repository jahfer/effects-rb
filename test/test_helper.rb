# frozen_string_literal: true

ENV['RAILS_ENV'] = "test"

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require "effects"

require 'active_support'
require 'active_support/test_case'
require 'active_support/testing/autorun'
