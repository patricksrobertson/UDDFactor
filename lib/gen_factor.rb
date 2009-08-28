module GenFactor
  LX_ZERO = 1000000
  SEGMENT_TWO = 5.0
  SEGMENT_THREE = 20.0
  TABLE_END = 120.0

  def sanitize_age(age)
    return  ((age * 12.0).round / 12.0)
  end
  module_function :sanitize_age
  
  def sanitize_interest(int)
	retVal = 0.0
	if int < 1.0
		retVal = int
	else
		retVal = int / 100.0
	end
	return retVal
  end
  module_function :sanitize_interest
  
  def round_factor(factor,sigFigs)
	return (factor * (10.0**sigFigs)).round / (10.0**sigFigs)
  end
  module_function :round_factor
end
