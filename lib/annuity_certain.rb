include GenFactor
module AnnuityCertain
    
  def annuity_certain(certain,seg1,seg2,seg3,round=12.0)
    retVal = 0.0
	retVal = annuity_certain_combined([certain,SEGMENT_TWO].min,seg1)
	if SEGMENT_TWO < certain 
		nil == seg2 ? seg2 = seg1 : seg2 = seg2
		retVal += annuity_certain_combined(SEGMENT_TWO,[certain,SEGMENT_THREE].min,seg2) 
	end
	if SEGMENT_THREE < certain 
		nil == seg3 ? seg3 = seg1 : seg3 = seg3
		retVal += annuity_certain_combined(SEGMENT_THREE,[certain,TABLE_END].min,seg3) 
	end
	return round_factor(retVal,round)
  end 
  module_function :annuity_certain 
  	  
  def interest_discount(int_rate)
	int_rate = sanitize_interest(int_rate)
	return 1.0 / (1.0 + int_rate)
  end
  module_function :interest_discount
  
  def yearly_discount(int_disc)
	return 12.0 * (1.0 - (int_disc ** (1.0/12.0)))
  end
  module_function :yearly_discount
  
  def annuity_certain_combined(*args)
	retVal = nil
	if 2 == args.size
		certain = args[0]
		interest = args[1]
		
		int_disc = interest_discount(interest)
		year_disc = yearly_discount(int_disc)
		retVal = (1.0 - (int_disc ** certain)) / year_disc		
	elsif 3 == args.size
		min_certain = args[0]
		max_certain = args[1]
		interest = args[2]
		
		int_disc = interest_discount(interest)
		year_disc = yearly_discount(int_disc)
		retVal = ((int_disc ** min_certain) - (int_disc ** max_certain)) / year_disc		
	end
	
	return retVal
  end
  module_function :annuity_certain_combined

end