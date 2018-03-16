# frozen_string_literal: true

require File.expand_path('../../test/dummy/config/environment.rb', __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../../test/dummy/db/migrate', __FILE__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../../db/migrate', __FILE__)
require 'rails/test_help'
require 'minitest/mock'

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path('../fixtures', __FILE__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + '/files'
  ActiveSupport::TestCase.fixtures :all
end

ActiveSupport::TestCase.set_fixture_class site: Scribo::Site
ActiveSupport::TestCase.set_fixture_class content: Scribo::Content

require 'minitest/reporters'
MiniTest::Reporters.use!

def rails_env_stub(env)
  old_env = Rails.env
  Rails.instance_variable_set('@_env', ActiveSupport::StringInquirer.new(env.to_s))
  yield
  Rails.instance_variable_set('@_env', ActiveSupport::StringInquirer.new(old_env))
end
