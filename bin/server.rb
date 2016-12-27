require 'webrick'
require_relative '../lib/base_controller'

class SomeController < BaseController
  def index
    if req.path == "/some_path"
      render_content("hello cats!", "text/html")
    else
      redirect_to("/some_path")
    end
  end
end

server = WEBrick::HTTPServer.new(Port: 3000)

server.mount_proc("/") do |request, response|
  SomeController.new(request, response).index
end

trap('INT') { server.shutdown }

server.start
