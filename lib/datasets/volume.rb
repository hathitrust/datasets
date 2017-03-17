
class Volume
  attr_reader :namespace, :id,
    :access_profile, :right

  def initialize(namespace:, id:, access_profile:, right:)
    @namespace = namespace.to_s
    @id = id.to_s
    @access_profile = access_profile.to_sym
    @right = right.to_sym
  end

end
