require 'filter'

class PdWorldFilter < Filter
  def matches?(volume)
    PD_RIGHTS.include?(volume.right) && (volume.right != :pdus) &&
      ACCESS_PROFILES.include?(volume.access_profile)
  end
end
