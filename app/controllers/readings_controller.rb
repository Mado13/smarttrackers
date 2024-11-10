# frozen_string_literal: true

class ReadingsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :authenticate_user!
  before_action :set_gauge
  before_action :set_reading, only: %i[update destroy approve]
  before_action :authorize_employee!, only: %i[new create]
  before_action :authorize_manager!, only: [:approve]

  def new
    @reading = @gauge.readings.build
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.update('new_reading_form', partial: 'form')
      end
    end
  end

  def create
    @reading = @gauge.readings.build(reading_params)
    if @reading.save
      render turbo_stream: [
        turbo_stream.append('readings', partial: 'readings/reading', locals: { reading: @reading }),
        turbo_stream.update('readings_content', partial: 'readings/content', locals: { gauge: @gauge }),
        turbo_stream_flash_message('success', 'Reading was successfully created.')
      ]
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update('modal_content',
                                                   template: 'readings/new',
                                                   locals: { gauge: @gauge, gauge_reading: @reading }),
                 status: :unprocessable_entity
        end
      end
    end
  end

  def update
    if @reading.update(reading_params)
      render turbo_stream: [
        turbo_stream.replace("reading_#{@reading.id}",
                             partial: 'readings/reading',
                             locals: { reading: @reading }),
        turbo_stream.update('modal', '')
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @reading.destroy
    render turbo_stream: [turbo_stream.remove("reading_#{@reading.id}"),
                          turbo_stream_flash_message('sucess', 'Reading was deleted.')]
  end

  def approve
    if @reading.approve
      render turbo_stream: [
        turbo_stream.replace("approval_status_#{@reading.id}",
                             partial: 'readings/approval_status',
                             locals: { reading: @reading }),
        turbo_stream.replace("reading_actions_#{@reading.id}",
                             partial: 'readings/actions',
                             locals: { reading: @reading, gauge: @gauge })
      ]
    else
      render turbo_stream: turbo_stream_flash_message('error', 'Could not approve reading.')
    end
  end

  private

  def set_gauge
    @gauge = Gauge.find(params[:gauge_id])
  end

  def set_reading
    @reading = @gauge.readings.find(params[:id])
  end

  def reading_params
    params.require(:reading).permit(:value, :date)
  end

  def authorize_employee!
    head :forbidden unless current_user.employee?
  end

  def authorize_manager!
    head :forbidden unless current_user.manager?
  end
end
