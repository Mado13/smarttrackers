# frozen_string_literal: true

class GaugesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_gauge, only: %i[show edit update destroy]

  def index
    @gauges = Gauge.all
    @gauge = Gauge.new
  end

  def show; end
  def edit; end
  def update; end
  def destroy; end

  def new
    @gauge = Gauge.new
    render :new
  end

  def create
    @gauge = Gauge.new(gauge_params)
    if @gauge.save
      render turbo_stream: [
        turbo_stream.append('gauges_list', partial: 'gauge', locals: { gauge: @gauge }),
        turbo_stream.update('new_gauge_form', ''),
        turbo_stream_flash_message('success', 'Gauge was successfully created.')
      ]
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_gauge
    @gauge = Gauge.find(params[:id])
  end

  def gauge_params
    params.require(:gauge).permit(:name, :start_date, :end_date, :unit, :time_unit)
  end
end
