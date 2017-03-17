require 'filter'

class PdFilter < Filter
  def matches?(volume)
    PD_RIGHTS.include?(volume.right) &&
      ACCESS_PROFILES.include?(volume.access_profile)
  end
end
