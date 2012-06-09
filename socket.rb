STDOUT.sync = true

require 'rubygems'
require 'bundler/setup'

require 'em-websocket'
require 'json'
require 'uri'
require 'logger'

require 'v8'

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

    def get_instance(game_id, instance_id, user_id)
      @data[game_id] ||= {}
      @data[game_id][instance_id] ||= Cartridge::GameInstance.new
      Cartridge::UserInstance.new(@data[game_id][instance_id], user_id)
    end
  end

  class GameInstance
    def initialize
      @store = {}
      @channel = EM::Channel.new
    end

    def handle(message)
      case message['method']
      when 'set'
        self.set(*message['args'])
        @channel.push(message)
      when 'join'

      else
        puts "Can't handle #{message.inspect}"
      end
    end

    def set(key, value)
      @store[key] = value
    end

    def delete(key)
      @store.delete key
    end

    def subscribe(*args, &block)
      @channel.subscribe(*args, &block)
    end

    def unsubscribe(*args, &block)
      @channel.unsubscribe(*args, &block)
    end

    def state
      @store
    end
  end

  class UserInstance
    extend Forwardable
    def_delegator :@game, :handle
    def_delegator :@game, :state

    def initialize(game_instance, user_id)
      @game = game_instance
      @user_id = user_id
    end

    def subscribe(*args, &block)
      @sid = @game.subscribe(*args, &block)
    end

    def quit
      @game.unsubscribe @sid
      @game.delete(@user_id)
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

    instance = server.get_instance(game_id, instance_id, user_id)

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


    puts "Initializing #{instance.state.inspect}"
    ws.send({
      method: 'init',
      state: instance.state
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



