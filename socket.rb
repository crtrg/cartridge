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

EM.run do
  @logger = Logger.new(STDOUT)
  @channels = {}
  @members = {}

  router = Router.new

  router.add '/:room/:user' do |ws, matcher|
    path = matcher[0]
    room_name = matcher[1]
    user_name = matcher[2]

    channel = @channels[room_name] || (@channels[room_name] = EM::Channel.new)
    sid = channel.subscribe { |msg| ws.send msg }

    @logger.info("#{sid} join #{room_name}")

    members = @members[room_name] || (@members[room_name] = {})
    members[sid] = user_name

    data = {
      :user    => 'system',
      :comment => "#{user_name} connected",
      :user_id => 0,
      :members => members
    }
    @logger.info(data)
    channel.push data.to_json

    ws.onmessage { |msg|
      puts "==========================================="
      puts "message"
      puts "==========================================="
      data = {
        :user    => user_name,
        :comment => msg,
        :user_id => sid
      }
      @logger.info(data)
      p channel
      channel.push(data.to_json)
    }

    ws.onclose {
      puts "==========================================="
      puts "close"
      puts "==========================================="
      members.delete(sid)
      data = {
        :user    => 'system',
        :comment => "#{user_name} disconnected",
        :user_id => 0,
        :members => members
      }
      @logger.info(data)
      channel.unsubscribe(sid)
    }

  end

  EM::WebSocket.start(:host=>'0.0.0.0', :port => 8081) do |ws|
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
      puts ws.inspect

      puts "==========================================="
      puts "open"
      puts "==========================================="

      # puts ws.request.path
      router.process ws.request['path'], ws
    }

  end

  @logger.info('Server Started')
end



