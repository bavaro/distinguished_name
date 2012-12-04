require 'test/unit'

if Kernel.respond_to?(:require_relative)
  require_relative "../lib/distinguished_name"
else
  require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "distinguished_name"))
end
