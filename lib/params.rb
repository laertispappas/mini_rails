require 'uri'

class Params
  def initialize(req, params)
    @params = params
    @params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
    @params.merge!(parse_www_encoded_form(req.body)) if req.body
  end

  def [](key)
    @params[key.to_sym] || @params[key.to_s]
  end


  def []=(key, val)
    @params[key.to_sym] = val
  end

  def to_s
    @params.to_json.to_s
  end

  def to_json
    @params.to_json
  end

  private

  def parse_www_encoded_form(www_encoded_form)
    build_params(parse(www_encoded_form))
  end


  def build_params(data)
    params = {}
    data.each do |pair|
      keys = pair[0..-2]
      val = pair.last
      current = params
      keys.each_with_index do |key, i|
        if i == keys.length - 1
          current[key] = val
        else
          current[key] ||= {}
          current = current[key]
        end
      end
    end
    params
  end

  def parse(key)
    key = URI.unescape(key)
    key.split('&').map! { |arr| arr.split(/\[|\]\[|\]|=/) }
      .map! { |arr| arr.reject { |val| val == "" } }
  end
end
