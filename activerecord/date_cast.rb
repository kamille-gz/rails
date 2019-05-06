begin
  require 'bundler/inline'
rescue LoadError
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise
end

gemfile(true) do
  source 'https://rubygems.org'

  # Activate the gem you are reporting the issue against.
  gem 'rails', github: 'rails/rails'
  gem 'sqlite3'
  gem 'pry'
end

require 'active_record'
require 'pry'
require 'minitest/autorun'
require 'logger'

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database:  ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.date "user_defined_date", null: false
  end
end

class Post < ActiveRecord::Base
end

class BugTest < Minitest::Test
  def test_without_transaction
    pp Post.new.attributes
    post = Post.create

    assert_equal post.user_defined_date?, false
    # NOTE: above code return
    #
    # Error:
    # BugTest#test_without_transaction:
    # ActiveRecord::NotNullViolation: SQLite3::ConstraintException: NOT NULL constraint failed: posts.user_defined_date
  end
end
