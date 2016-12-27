class Session
  def initialize(req)
    cookie = req.cookies.find { |cookie| cookie.try(:name) == "_min_rails_app" }
    @session = cookie ? JSON.parse(cookie.value) : {}
  end

  def [](key)
    @session[key]
  end

  def []=(key, val)
    @session[key] = val
  end

  def store_session(res)
    res.cookies << WEBrick::Cookie.new("_min_rails_app", @session.to_json)
  end
end
