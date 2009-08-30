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
  
  def validate_float(inFloat) 
	returnValue = []
	if nil == inFloat
		returnValue << "cannot be null "
	else
		begin 
			Float(inFloat)
			returnValue = nil 
		rescue Exception => err 
			returnValue = " #{err.message   }" 
		end 
	end
	return returnValue
  end   
  module_function :validate_float
  
  def set_default(inVariable,default)
	returnValue = inVariable
	if nil == inVariable
		returnValue = default
	else	
		if (inVariable.class == Object::String || Object::Array)
			if inVariable.empty?
				returnValue = default
			end
		elsif inVariable.class == Object::Float
			if nil == inVariable
				returnValue = default
			end
		end
	end
	return returnValue
  end
end
