class ApplicationController < ActionController::Base
  protected

  def turbo_stream_flash_message(type, message)
    turbo_stream.prepend(
      'flash_messages',
      partial: 'shared/flash',
      locals: { type: type, message: message }
    )
  end
end
