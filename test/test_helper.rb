require 'minitest/autorun'
require 'pry-rescue/minitest' if ENV['DEBUG']

$LOAD_PATH.unshift(File.join(File.expand_path(__dir__), '..', 'lib'))
require 'hamlish_liquid'