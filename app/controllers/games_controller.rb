
class GamesController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :edit, :create, :destroy]
  skip_before_filter :verify_authenticity_token, :if =>lambda{ params[:push_token].present?}, :only => [:update]
  def index
    @games = Game.all
  end

  def show
    @token = current_user.try(:id) || "guest_#{(rand*100000000).floor}"
    @game = Game.find(params[:id])
  end

  def new
    @game = Game.new
  end

  def edit
    @game = Game.find(params[:id])
  end

  def create
    @game = Game.new(params[:game])
    @game.creator = current_user
    if @game.save
      redirect_to games_path, notice: 'Game was successfully created.'
    else
      render action: "new"
    end
  end

  # Supports curl. For example:
  # curl -X PUT http://crtrg.com/games/1 -F push_token=abc123etc -F package=@file.js
  def update
    @game = Game.find(params[:id])
    if params[:push_token] != @game.push_token
      authenticate_user!
      if @game.update_attributes(params[:game])
        redirect_to @game, notice: 'Game was successfully updated.'
      else
        render action: "edit"
      end
    else
      @game.package = params[:package].read
      if @game.save
        render :text => "game updated\n"
      else
        render :text => @game.errors.full_messages.join("\n")+"\n"
      end
    end
  end

  def destroy
    @game = Game.find(params[:id])
    @game.destroy

    redirect_to games_url
  end
end
