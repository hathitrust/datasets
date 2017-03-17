require 'filter'

class FullSetFilter < Filter
  def matches?(volume)
    (PD_RIGHTS.include?(volume.right) || IC_RIGHTS.include?(volume.right)) &&
      ACCESS_PROFILES.include?(volume.access_profile)
  end
end
