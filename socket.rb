STDOUT.sync = true

require 'rubygems'
require 'bundler/setup'

require 'em-websocket'
require 'json'
require 'uri'
require 'logger'

# require 'v8'

# load rails env!
APP_PATH = File.expand_path('../config/application',  __FILE__)
require File.expand_path('../config/boot',  __FILE__)
ENV["RAILS_ENV"] ||= "development"
require APP_PATH
Rails.application.require_environment!

class Router
  def initialize
  end

  def add path, &block
    @routes ||= []
    @routes << {
      path: Regexp.new("^#{ path.gsub(/\//, "\\/").gsub(/:(\w*)/, "(\\w*)") }$"),
      callback: block
    }
  end

  def process path, ws
    @routes.each do |route|
      parms = path.match(route[:path])
      if parms
        route[:callback].call(ws, parms)
        return
      end
    end
  end
end

module Cartridge
  class Server
    def initialize
      @data = {}
    end

    def get_instance(game_id, instance_id, user)
      @data[game_id] ||= {}
      @data[game_id][instance_id] ||= Cartridge::GameInstance.new
      Cartridge::UserInstance.new(@data[game_id][instance_id], user)
    end
  end

  class GameInstance
    attr_accessor :players

    def initialize
      @store = {}
      @players = []
      @channel = EM::Channel.new
    end

    def handle(message)
      case message['method']
      when 'set'
        self.set(*message['args'])
        @channel.push(message)
      when 'join'
        # send "user joined" system message
      when 'chat'
        user = message[:_user]
        msg  = message['args'][0]
        # send message to everyone
        @channel.push method: 'chat', username: user.username, user_id: user.id, message: msg
      else
        puts "Can't handle #{message.inspect}"
      end
    end

    def set(key, value)
      @store[key] = value
    end

    def add_player user
      players.push user

      # tell the world about the player
      update_players
      @channel.push({method: 'system', message: "#{user.username} has joined"})
    end

    def remove_player user
      players.delete user
      @channel.push({method: 'system', message: "#{user.username} has left"})
    end

    def delete(key)
      @store.delete key
      @channel.push({
        method: 'delete',
        args: [key]
      })
    end

    def subscribe(*args, &block)
      # connect player to the world
      @channel.subscribe(*args, &block)
    end

    def unsubscribe(*args, &block)
      @channel.unsubscribe(*args, &block)
    end

    def state
      @store
    end

    def update_players
      @channel.push({method: 'players', players: players})
    end

  end

  class UserInstance
    extend Forwardable
    def_delegator :@game, :state
    def_delegator :@game, :players

    def initialize(game_instance, user)
      @game = game_instance
      @user = user
      @user_id = user.id
    end

    def subscribe(*args, &block)
      @sid = @game.subscribe(*args, &block)
      @game.add_player @user
    end

    def quit
      @game.unsubscribe @sid
      @game.delete @user.id
      @game.remove_player @user
      @game.update_players
    end

    def handle payload
      payload[:_user] = @user
      @game.handle payload
    end

    def game
      @game
    end
  end

  class User
    attr_accessor :username, :id
    def initialize id, username
      @id = id
      @username = username
    end
  end
end

server = Cartridge::Server.new

EM.run do
  @logger = Logger.new(STDOUT)

  router = Router.new

  router.add '/game/:game_id/:instance_id/:user_id' do |ws, matcher|
    game_id     = matcher[1]
    instance_id = matcher[2]
    user_id     = matcher[3]

    # get username from server?
    user = {username: user_id, id: user_id}
    if User.exists?(id: user_id)
      _user = User.find user_id
      user  = {username: _user.username, id: _user.id}
    end
    user = Cartridge::User.new user[:id], user[:username]

    instance = server.get_instance(game_id, instance_id, user)

    instance.subscribe do |message|
      puts "Sending #{message.inspect}"
      ws.send message.to_json
    end

    ws.onmessage do |message|
      puts "Handling #{message.inspect}"
      instance.handle(JSON.parse(message))
    end

    ws.onclose do
      instance.quit
    end

    # tell new player about the world
    puts "initializing #{instance.state.inspect}"
    ws.send({
      method: 'init',
      state: instance.state,
      players: instance.players
    }.to_json)
  end


  @root = {}

  # join / leave echo bot
  router.add '/' do |ws, matcher|
    @root[:members] ||= {}
    @root[:channel] ||= EM::Channel.new

    members = @root[:members]
    channel = @root[:channel]

    if members.size > 10
      puts "too many members"
      channel.push({message: 'someone got bounced :('})
      ws.close_connection
    else
      sid = channel.subscribe {|msg| ws.send msg}
      members[sid] = 'member'

      ws.onclose {
        puts "closing a connection"
        members.delete(sid)
        channel.unsubscribe(sid)
        channel.push({message: "user #{sid} left"}.to_json)
      }

      channel.push({message: "user #{sid} joined"}.to_json)
    end
  end


  # @demo = {}
  # router.add '/demo/:token' do |ws, matcher|
  #   @demo[:members] ||= {}
  # end

  # router.add '/:room/:user' do |ws, matcher|
  #   path = matcher[0]
  #   room_name = matcher[1]
  #   user_name = matcher[2]

  #   channel = @channels[room_name] || (@channels[room_name] = EM::Channel.new)
  #   sid = channel.subscribe { |msg| ws.send msg }

  #   @logger.info("#{sid} join #{room_name}")

  #   members = @members[room_name] || (@members[room_name] = {})
  #   members[sid] = user_name

  #   data = {
  #     :user    => 'system',
  #     :comment => "#{user_name} connected",
  #     :user_id => 0,
  #     :members => members
  #   }
  #   @logger.info(data)
  #   channel.push data.to_json

  #   ws.onmessage { |msg|
  #     puts "==========================================="
  #     puts "message"
  #     puts "==========================================="
  #     data = {
  #       :user    => user_name,
  #       :comment => msg,
  #       :user_id => sid
  #     }
  #     @logger.info(data)
  #     p channel
  #     channel.push(data.to_json)
  #   }

  #   ws.onclose {
  #     puts "==========================================="
  #     puts "close"
  #     puts "==========================================="
  #     members.delete(sid)
  #     data = {
  #       :user    => 'system',
  #       :comment => "#{user_name} disconnected",
  #       :user_id => 0,
  #       :members => members
  #     }
  #     @logger.info(data)
  #     channel.unsubscribe(sid)
  #   }
  # end

  EM::WebSocket.start(:host=>'0.0.0.0', :port => ENV['SOCKET_PORT']) do |ws|
    # can't route until after ws.onopen fires because we don't
    # have path information before that.
    #
    # `puts ws.inspect` returns
    #
    # before:
    #   #<EventMachine::WebSocket::Connection:0x007ffeeab21970 @signature=28,
    #   @options={:host=>"0.0.0.0", :port=>8081}, @debug=false, @secure=false,
    #   @tls_options={}, @data="">
    #
    # after:
    #   #<EventMachine::WebSocket::Connection:0x007ffeeab21970 @signature=28,
    #   @options={:host=>"0.0.0.0", :port=>8081}, @debug=false, @secure=false,
    #   @tls_options={}, @data=nil, @onopen=#<Proc:0x007ffeeab21650@chat.rb:99>,
    #   @handler=#<EventMachine::WebSocket::Handler76:0x007ffeeab26d58
    #   @request={"method"=>"GET", "path"=>"/test/lips", "query"=>{},
    #   "upgrade"=>"WebSocket", "connection"=>"Upgrade",
    #   "host"=>#<Addressable::URI:0x3fff75593850 URI:ws://adam.local:8081>,
    #   "origin"=>"http://localhost:5000", "sec-websocket-key1"=>"9.28_ 2 c
    #   D&1I1[07  0", "sec-websocket-key2"=>"P 3481V 8 R53cZ58R6",
    #   "third-key"=>"\x99\xDB\xABox\\g\xA4"},
    #   @connection=#<EventMachine::WebSocket::Connection:0x007ffeeab21970 ...>,
    #   @debug=false, @state=:connected, @data="">>
    #
    ws.onopen {
      puts "opened a connection to #{ ws.request['path'] }"
      router.process ws.request['path'], ws
    }

  end

  @logger.info('Server Started')
end



