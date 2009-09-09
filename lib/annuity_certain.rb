include GenFactor
module AnnuityCertain
    
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
	  
	  round_factor(retVal,round)
  end #end method annuity_certain
  module_function :annuity_certain 
  	  
  def interest_discount(int_rate)
	  int_rate = sanitize_interest(int_rate)
	  1.0 / (1.0 + int_rate)
  end #emd method interest_discount
  
  def yearly_discount(int_disc)
	  12.0 * (1.0 - (int_disc ** (1.0/12.0)))
  end #end method yearly_discount
  
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
  end #end method annuity_certain_combined

end #end module AnnuityCertain
