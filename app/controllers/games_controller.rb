
class GamesController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :edit, :create, :destroy]
  skip_before_filter :verify_authenticity_token, :if =>lambda{ params[:push_token].present?}, :only => [:update]
  before_filter :load_and_authorize_game, :only => [:edit, :update, :destroy]
  before_filter :only_creators, :only => [:new, :edit, :create, :update, :destroy]

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
  end

  def create
    @game = Game.new(params[:game])
    @game.creator = current_user
    if @game.save
      flash[:success] = 'Game was successfully created.'
      redirect_to games_path
    else
      render action: "new"
    end
  end

  # Supports curl. For example:
  # curl -X PUT http://crtrg.com/games/1 -F push_token=abc123etc -F package=@file.js
  def update
    if params[:push_token]
      @game.package = params[:package].read
      if @game.save
        render :text => "game updated\n"
      else
        render :text => @game.errors.full_messages.join("\n")+"\n"
      end
    else
      authenticate_user!
      if @game.update_attributes(params[:game])
        redirect_to @game
      else
        render action: "edit"
      end
    end
  end

  def destroy
    @game.destroy
    redirect_to games_url
  end

  private
  def load_and_authorize_game
    @game = Game.find(params[:id])
    if params[:push_token] != @game.push_token && @game.creator != current_user
      redirect_to games_path
    end
  end

  def only_creators
    if !current_user.creator
      flash[:error] = "We're sorry, your account has not be authorized to create games yet. Contact us on twitter <a href='http://twitter.com/crtrg'>@crtrg</a>"
      redirect_to games_path
    end
  end
end
