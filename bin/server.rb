require 'webrick'

server = WEBrick::HTTPServer.new(Port: 3000)

server.mount_proc("/") do |request, response|
   response.body = request["request_uri"]
end

trap('INT') { server.shutdown }

server.start
