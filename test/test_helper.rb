#require 'rubygems'
require "mortality_table"
require "gen_factor"
require "annuity_certain"
require "udd_factor"
require "actuarial_factor"
#include UDDFactor
#require 'active_support/test_case'
$:.unshift(File.dirname(__FILE__) + '/../lib')
#ENV['RAILS_ENV'] = 'test'
#ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..' 
require 'test/unit' 