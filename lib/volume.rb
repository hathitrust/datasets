
class Volume
  attr_reader :namespace, :id,
    :access_profile, :right

  def initialize(namespace:, id:, access_profile:, right:)
    @namespace = namespace
    @id = id
    @access_profile = access_profile
    @right = right
  end

end
