require 'webrick'
require_relative '../lib/base_controller'
require_relative '../lib/router'
require_relative '../fixtures'

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


router = Router.new
router.draw do
  get Regexp.new("^/users$"), UsersController, :index
  get Regexp.new("^/users/new$"), UsersController, :new
  post Regexp.new("^/users"), UsersController, :create
end


server = WEBrick::HTTPServer.new(Port: 3000)

server.mount_proc("/") do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }

server.start
