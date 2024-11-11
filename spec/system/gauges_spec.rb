# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Gauges Management', type: :system do
  let(:employee) { create(:user, :employee) }
  let(:manager) { create(:user, :manager) }

  before do
    create_list(:gauge, 4, name: 'Test Gauge')
  end

  context 'when logged in as an employee' do
    before do
      sign_in employee
    end

    it 'displays all gauges and allows creating a new gauge', js: true do
      visit gauges_path

      expect(page).to have_css('.gauge-item', count: 4)

      expect(page).to have_link('New gauge')

      click_link 'New gauge'

      expect(page).to have_css('#modal-headline', text: 'New Gauge')

      fill_in 'Name', with: 'New Test Gauge'
      fill_in 'Start date', with: Date.today
      fill_in 'End date', with: Date.today + 1.month
      select 'kWh', from: 'Unit'
      select 'month', from: 'Time unit'

      click_button 'Create Gauge'

      expect(page).to have_content('Gauge was successfully created.')
      expect(page).to have_css('.gauge-item', count: 5)
      expect(page).to have_content('New Test Gauge')
    end

    it 'shows validation errors when creating a gauge with invalid data', js: true do
      visit gauges_path
      click_link 'New gauge'

      click_button 'Create Gauge'

      expect(page).to have_content("can't be blank")
    end

    it 'allows the employee to view a gauge and its readings' do
      gauge = Gauge.first
      create_list(:reading, 3, gauge: gauge, value: 100.0, date: gauge.start_date)

      visit gauges_path

      click_link href: gauge_path(gauge)

      expect(page).to have_content(gauge.name)
      expect(page).to have_content('Readings')

      expect(page).to have_css('table tbody tr', count: 3)
    end

    it 'allows the employee to add a new reading', js: true do
      gauge = create(:gauge, start_date: Date.today - 1.month, end_date: Date.today + 1.month)

      visit gauge_path(gauge)

      expect(page).to have_link('Add Reading')
      click_link 'Add Reading'

      expect(page).to have_css('#modal-headline', text: 'New Reading')


      fill_in 'Date', with: gauge.start_date
      fill_in 'Value', with: '150.0'

      click_button 'Create Reading'

      expect(page).to have_content('Reading was successfully created.')
      expect(page).to have_css('table tbody tr', count: 1)
      expect(page).to have_content('150.0')
    end

    it 'shows validation error when adding a reading with date outside gauge range', js: true do
      gauge = create(:gauge, start_date: Date.today - 1.month, end_date: Date.today + 1.month)

      visit gauge_path(gauge)
      click_link 'Add Reading'

      invalid_date = (gauge.end_date + 1.day).strftime('%Y-%m-%d')

      fill_in 'Date', with: invalid_date
      fill_in 'Value', with: '150.0'

      click_button 'Create Reading'

      expect(page).to have_content("must be within gauge's date range")
    end
  end

  context 'when logged in as a manager' do
    before do
      sign_in manager
    end

    it 'displays all gauges but does not show the "New Gauge" button' do
      visit gauges_path

      expect(page).to have_css('.gauge-item', count: 4)

      expect(page).not_to have_link('New gauge')
    end

     it 'allows the manager to approve readings with confirmation', js: true do
      gauge = create(:gauge, start_date: Date.today - 1.month, end_date: Date.today + 1.month)
      reading = create(:reading, gauge: gauge, value: 100.0, date: gauge.start_date, approved: false)

      visit gauge_path(gauge)

      within("#reading_#{reading.id}") do
        expect(page).to have_link('Approve')
      end

      accept_confirm do
        within("#reading_#{reading.id}") do
          click_link 'Approve'
        end
      end

      within("#reading_#{reading.id}") do
        expect(page).not_to have_link('Approve')
        expect(page).to have_css('.approved') 
        expect(page).not_to have_css('pending')
      end
    end
  end
end
