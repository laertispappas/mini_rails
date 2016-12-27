require 'webrick'

class BaseController
  attr_reader :req, :res
  class Error < StandardError; end
  class HasRespondedError < Error; end

  def initialize(req, res, params = {})
    @req, @res = req, res
    @params = params
  end

  def redirect_to(url)
    validate_response_is_not_built!

    res.body = "<HTML><a href=\"#{url.to_s}\">#{url.to_s}</a>.</HTML>\n"
    res['Location']  = url.to_s
    res.status = 302

    @_response_is_built = true
  end

  def render_content(content, content_type)
    validate_response_is_not_built!

    res.content_type = content_type
    res.body = content
    @_response_is_built = true
  end

  def render(template_name)
  end

  private
  def validate_response_is_not_built!
    raise HasRespondedError.new('Already responded') if response_is_built?
  end

  def response_is_built?
    @_response_is_built == true
  end
end
