#!/usr/bin/env ruby

# Bundler binstub boilerplate
require "pathname"
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile",
  Pathname.new(__FILE__).realpath)

require "rubygems"
require "bundler/setup"

# Project specific code
require_relative '../lib/datasets/cli.rb'

Datasets::CLI.start(ARGV)
