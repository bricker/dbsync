require 'bundler/setup'
require 'fileutils'
Bundler.require

RSpec.configure do |config|
  config.after do
    FileUtils.rm(Dir[File.expand_path("../local/*", __FILE__)])
  end
end
