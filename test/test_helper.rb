require 'test/unit'

if Kernel.respond_to?(:require_relative)
  require_relative "../lib/distinguished_name"
else
  require File.join(File.dirname(caller[0]), "../lib/distinguished_name")
end
