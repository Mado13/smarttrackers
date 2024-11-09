# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.destroy_all

User.create!(
  email: 'employee@smarttrackers.com',
  password: 'Employee123',
  password_confirmation: 'Employee123',
  first_name: 'Lydia',
  last_name: 'Darashenko',
  role: 'employee'
)

User.create!(
  email: 'manager@smarttrackers.com',
  password: 'Manager123',
  password_confirmation: 'Manager123',
  first_name: 'Shantal',
  last_name: 'Cohen',  
  role: 'manager'
)
