
module Datasets
  class Volume
    attr_reader :namespace, :id,
      :access_profile, :right

    def initialize(namespace:, id:, access_profile:, right:)
      @namespace = namespace.to_s
      @id = id.to_s
      @access_profile = access_profile.to_sym
      @right = right.to_sym
    end

    def ==(other)
      namespace == other.namespace &&
        id == other.id &&
        access_profile == other.access_profile &&
        right == other.right
    end

    alias_method :eql?, :==

    def to_h
      {
        namespace: namespace, id: id,
        access_profile: access_profile, right: right
      }
    end

  end
end
