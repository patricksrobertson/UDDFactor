##
# @author Patrick Robertson
# @ version 1.0.0
#
# AnnuityCertain generates a mortalityless certain factor given 1 or more interest segment rates.
##

include GenFactor
module AnnuityCertain
  ##
  # returns an annuity certain over all three interest segments.  When calculating a single segment
  # annuity certain factor, either place nil in seg2 & seg3 or call {#annuity_certain_combined} with
  # the certain period and interest rate.
  #
  # @example 6 year certain factor with 3 segment interest
  #  "annuity_certain(6.0,5.44,5.22,5.69)"
  # 
  # @since version 1.0.0
  ##
  def annuity_certain(certain,seg1,seg2,seg3,round=12.0)
    retVal = 0.0
	  retVal = annuity_certain_combined([certain,GenFactor::SEGMENT_TWO].min,seg1)
	  
	  if GenFactor::SEGMENT_TWO < certain 
		  nil == seg2 ? seg2 = seg1 : seg2 = seg2
		  retVal += annuity_certain_combined(GenFactor::SEGMENT_TWO,[certain,GenFactor::SEGMENT_THREE].min,seg2) 
	  end
	  
	  if GenFactor::SEGMENT_THREE < certain 
		  nil == seg3 ? seg3 = seg1 : seg3 = seg3
		  retVal += annuity_certain_combined(GenFactor::SEGMENT_THREE,[certain,GenFactor::TABLE_END].min,seg3) 
	  end
	  
	  GenFactor::round_factor(retVal,round)
  end
  module_function :annuity_certain 
  

  
  ##
  # Calculates either a simple segment, or one of three segments of an annuity certain
  # factor.
  # 
  # @param [Array] args - If there are 2 parameters, calculate a simple segment annuity certain.
  #                       If there are 3, calculate that segment given min and max years.
  #
  # @example simple annuity certain
  # "annuity_certain_combined(6.0,5.44)"
  # @example 2nd annuity certain segment
  # "annuity_certain_combined(5.0,20.0,5.24)"
  #
  # @since version 1.0.0
  ##
  def annuity_certain_combined(*args)
	  retVal = nil
	  case args.size
	    when 2
		    certain = args[0]
		    interest = args[1]
		
		    int_disc = interest_discount(interest)
		    year_disc = yearly_discount(int_disc)
		    
		    (1.0 - (int_disc ** certain)) / year_disc		
	    when 3
		    min_certain = args[0]
		    max_certain = args[1]
		    interest = args[2]
		
		    int_disc = interest_discount(interest)
		    year_disc = yearly_discount(int_disc)
		    
        ((int_disc ** min_certain) - (int_disc ** max_certain)) / year_disc		
		else
		    nil
	  end
  end
  module_function :annuity_certain_combined

end
