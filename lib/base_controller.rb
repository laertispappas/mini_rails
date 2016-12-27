require 'webrick'

require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require_relative './params'

require_relative './session'

class BaseController
  attr_reader :req, :res, :params
  class Error < StandardError; end
  class HasRespondedError < Error; end

  def initialize(req, res, params = {})
    @req, @res = req, res
    @params = Params.new(req, params)
  end

  def redirect_to(url)
    validate_response_is_not_built!

    res.body = "<HTML><a href=\"#{url.to_s}\">#{url.to_s}</a>.</HTML>\n"
    res['Location']  = url.to_s
    res.status = 302

    @_response_is_built = true

    session.store_session(res)
  end

  def render_content(content, content_type)
    validate_response_is_not_built!

    res.content_type = content_type
    res.body = content
    @_response_is_built = true
    session.store_session(res)
  end

  def render(template_name)
    view = File.read("views/#{self.class.name.underscore.gsub('_controller', '')}/#{template_name}.html.erb")
    template = ERB.new(view).result(binding)
    render_content(template, "text/html")
  end

  private
  def session
    @_session ||= Session.new(req)
  end

  def validate_response_is_not_built!
    raise HasRespondedError.new('Already responded') if response_is_built?
  end

  def response_is_built?
    @_response_is_built == true
  end
end
