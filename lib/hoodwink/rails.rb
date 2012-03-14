if defined?(Rails) && Rails::VERSION::MAJOR == 2
  Rails.configuration.after_initialize do
    Hoodwink.data_file_paths = File.join(Rails.root, 'hoodwink/data/%s' % Rails.env)
    Hoodwink.reload
  end
elsif defined?(Rails) && Rails::VERSION::MAJOR >= 3
  require 'rails'
  module Hoodwink
    class Railtie < Rails::Railtie

      initializer "hoodwink.set_default_file_paths" do
        Hoodwink.data_file_paths = File.join(Rails.root, 'hoodwink/data/%s' % Rails.env)
      end

      config.after_initialize do
        Hoodwink.reload
      end
    end
  end
end
