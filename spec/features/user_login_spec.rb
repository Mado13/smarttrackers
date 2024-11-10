require 'rails_helper'

RSpec.describe 'User login', type: :feature, js: true do
  let(:user) { create(:user) }
  
  before do
    user
    visit new_user_session_path
  end

  context 'with valid credentials' do
    it 'signs user in successfully' do
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'Log in'
      
      expect(page).to have_current_path(root_path, wait: 5)
    end
  end

  context 'with invalid credentials' do
    it 'shows error with wrong password' do
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: 'wrongpassword'
      click_button 'Log in'
      
      expect(page).to have_content('Invalid Email or password')
      expect(page).to have_current_path(new_user_session_path, wait: 5)
    end

    it 'shows error with non-existent email' do
      fill_in 'user[email]', with: 'nonexistent@example.com'
      fill_in 'user[password]', with: 'password123'
      click_button 'Log in'
      
      
      expect(page).to have_content('Invalid Email or password')
      expect(page).to have_current_path(new_user_session_path, wait: 5)
    end
  end
end
