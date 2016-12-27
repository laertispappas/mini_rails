class User
  attr_reader :name
  
  def self.all
    @users ||= []
  end

  def initialize(attrs = {})
    attrs ||= {}
    @name = attrs["name"]
  end

  def save
    return false unless @name.present?

    User.all << self
    true
  end

  def inspect
    { name: @name }
  end
end

u1 = User.new('name' => 'pappas')
u1.save
