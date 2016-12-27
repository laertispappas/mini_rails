require_relative './base_controller'
class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    req.path =~ @pattern && @http_method == req.request_method.downcase.to_sym
  end

  def run(req, res)
    route_params = req.path.match(@pattern)
    controller = @controller_class.new(req, res, build_hash(route_params))
    controller.send(:invoke_action, @action_name)
  end

  def build_hash(route_params)
    route_params.names.inject({}) do |hash, name|
      hash.tap { |h| h[name] = route_params[name] }
    end
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    @routes.find { |route| route.matches?(req) }
  end

  def run(req, res)
    route = match(req)
    !route.nil? ? route.run(req, res) : res.status = 404
  end

  def draw(&block)
    instance_eval(&block)
    define_controller_helpers
  end

  def define_controller_helpers
    index_route = @routes.find { |route| route.action_name == :index }
    if index_route
      define_path_helper(index_route, true)
      #define_url_helper(index_route, true)
    end

    show_route = @routes.find { |route| route.action_name == :show }
    if show_route
      define_path_helper(show_route, false)
      #define_url_helper(show_route, false)
    end
  end

  def define_path_helper(route, plural)
    BaseController.send(:define_method, methodify(route.controller_class, "path", plural)) do |obj = nil|
      resource_path = route.pattern.inspect[/(\/[[:alnum:]]+)+/]
      resource_id = route.action_name == :show ? "\\#{obj.try(:id) ? obj.id : obj}" : ""
      return resource_path + resource_id
    end
  end

  def define_url_helper(route, plural)
    raise NotImplementedError
  end

  def methodify(controller_class, suffix, plural = false)
    class_name = uncontrollerize(controller_class)
    (plural ? class_name.pluralize.downcase : class_name.downcase) + "_#{suffix}"
  end

  def uncontrollerize(controller_class)
    controller_class.name.match(/(.+)Controller/)[1]
  end
end
