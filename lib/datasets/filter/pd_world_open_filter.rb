require 'filter'

class PdWorldOpenFilter < Filter
  def matches?(volume)
    PD_RIGHTS.include?(volume.right) && (volume.right != :pdus) &&
      OPEN_ACCESS_PROFILES.include?(volume.access_profile)
  end
end
