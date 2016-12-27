class HashWithIndifferentAccess < Hash
  def [](key)
    super(key.to_sym)
  end

  def []=(key, val)
    super(key.to_sym, val)
  end

  def merge(other_hash)
    super(other_hash).inject(HashWithIndifferentAccess.new) do |hash, (k, v)|
      hash.tap { |h| h[k] = v }
    end
  end
end

class Flash
  def initialize(req)
    @req = req
    my_cookie = req.cookies.find { |cookie| cookie.try(:name) == "_min_rails_app" }
    @flash = HashWithIndifferentAccess.new
    @now = HashWithIndifferentAccess.new

    if my_cookie
      JSON.parse(my_cookie.value).each do |k, v|
        @now[k] = v
      end
    end
  end

  def [](key)
    @flash.merge(@now)[key]
  end

  def []=(key, val)
    @flash[key] = val
    @now[key] = val
  end

  def now
    @now
  end

  def store_flash(res)
    res.cookies << WEBrick::Cookie.new("_min_rails_app", @flash.to_json)
  end
end
