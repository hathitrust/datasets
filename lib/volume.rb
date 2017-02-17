
class Volume
  attr_reader :namespace, :id,
    :access_profile, :right, :source

  def initialize(namespace:, id:, access_profile:, right:, source:)
    @namespace = namespace
    @id = id
    @access_profile = access_profile
    @right = right
    @source = source
  end

end
