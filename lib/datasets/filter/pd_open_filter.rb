require "datasets/filter"

module Datasets
  class PdOpenFilter < Filter
    def matches?(volume)
      PD_RIGHTS.include?(volume.right) &&
        OPEN_ACCESS_PROFILES.include?(volume.access_profile)
    end
  end
end
