# Filters volumes based on criteria.
module Datasets
  class Filter
    PD_RIGHTS = [:"cc-by-3.0",
                 :"cc-by-4.0",
                 :"cc-by-nc-3.0",
                 :"cc-by-nc-4.0",
                 :"cc-by-nc-nd-3.0",
                 :"cc-by-nc-nd-4.0",
                 :"cc-by-nc-sa-3.0",
                 :"cc-by-nc-sa-4.0",
                 :"cc-by-nd-3.0",
                 :"cc-by-nd-4.0",
                 :"cc-by-sa-3.0",
                 :"cc-by-sa-4.0",
                 :"cc-zero",
                 :"ic-world",
                 :pd,
                 :pdus,
                 :"und-world"].to_set

    IC_RIGHTS = [:ic, :icus, :und, :op].to_set

    ACCESS_PROFILES = [:google, :open].to_set
    OPEN_ACCESS_PROFILES = [:open].to_set

    def new; end

    # Check if a single volume is in the set described by
    # this filter.
    # @param [Volume] volume
    # @return [Boolean]
    def matches?(volume); end
  end
end
