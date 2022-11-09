# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'sequel'
require 'yaml'

module YouFind
  # Configuration for the App
  class App < Roda
    plugin :environments
    # CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
    # YT_TOKEN = CONFIG['API_KEY']
    configure do
      Figaro.application = Figaro::Application.new(
        environment: environment,
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load
      def self.config = Figaro.env

      configure :development, :test do
        ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
        ENV['YT_TOKEN'] = config.API_KEY
      end

      # Database Setup
      db = Sequel.connect(ENV.fetch('DATABASE_URL', nil))
      def self.db = db
    end
  end
end
