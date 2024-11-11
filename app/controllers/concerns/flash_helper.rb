module FlashHelper
  extend ActiveSupport::Concern

  included do
    helper_method :turbo_stream_flash_message
  end

  def turbo_stream_flash_message(type, message)
    turbo_stream.prepend(
      'flash_messages',
      partial: 'shared/flash',
      locals: { type: type, message: message }
    )
  end
end
