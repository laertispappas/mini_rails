require 'webrick'
require_relative '../lib/base_controller'

class SomesController < BaseController
  def index
    if req.path == "/some_path"
      render_content("hello cats!", "text/html")
    else
      redirect_to("/some_path")
    end
  end

  def show
    render :show
  end
end

server = WEBrick::HTTPServer.new(Port: 3000)

server.mount_proc("/") do |request, response|
  SomesController.new(request, response).show
end

trap('INT') { server.shutdown }

server.start
