class SocketDemoController < ApplicationController
  def index
  end

  def game_demo
    @token = current_user.try(:id) || "guest_#{(rand*100000000).floor}"
  end
end
