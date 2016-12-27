require 'webrick'
require_relative '../lib/base_controller'
require_relative '../fixtures'

class SomesController < BaseController
  def content
    render_content("hello there!", "text/html")
  end

  def index
  end

  def show
    session['count'] ||= 0
    session['count'] += 1
    render :show
  end
end

class UsersController < BaseController
  def index
    @users = User.all
    render :index
  end

  def new
    @user = User.new
    render :new
  end

  def create
    @user = User.new(params['user'])
    if @user.save
      redirect_to("/users")
    else
      render :new
    end
  end
end

server = WEBrick::HTTPServer.new(Port: 3000)

server.mount_proc("/") do |req, res|
  case [req.request_method, req.path]
  when ['GET', '/content']
    SomesController.new(req, res).content
  when ['POST', '/users']
    UsersController.new(req, res, {}).create
  when ['GET', '/users/new']
    UsersController.new(req, res, {}).new
  when ['GET', '/users']
    UsersController.new(req, res).index
  else
    SomesController.new(req, res).show
  end
end

trap('INT') { server.shutdown }

server.start
