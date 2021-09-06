class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    stream_from "appearance_channel"

    ActionCable.server.broadcast('appearance_channel', { messages: "hello" })
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
