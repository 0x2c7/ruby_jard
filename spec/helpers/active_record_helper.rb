# frozen_string_literal: true

require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

# Set up database tables and columns
ActiveRecord::Schema.define do
  create_table :ar_pets, force: true do |t|
    t.string :name
    t.integer :age
  end

  create_table :ar_posts, force: true do |t|
    t.string :title
    t.string :description
    t.datetime :created_at
  end
end

# Set up model classes
class ArPet < ActiveRecord::Base; end
class ArPost < ActiveRecord::Base; end
