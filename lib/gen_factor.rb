module GenFactor
  LX_ZERO = 1000000
  SEGMENT_TWO = 5.0
  SEGMENT_THREE = 20.0
  TABLE_END = 120.0

  def sanitize_age(age)
    return  ((age * 12.0).round / 12.0)
  end # end method sanitize_age
  
  def sanitize_interest(int)
	  retVal = 0.0
	  if int < 1.0
		  retVal = int
	  else
		  retVal = int / 100.0
	  end
	  return retVal
  end #end method sanitize_interest
  
  def round_factor(factor,sigFigs)
	  return (factor * (10.0**sigFigs)).round / (10.0**sigFigs)
  end #end method round_factor
  
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
  end #end method validate_float   
  
  def set_default(inVariable,default)
	  returnValue = inVariable
	  if nil == inVariable
		  returnValue = default
	  else	
		  begin
			  if inVariable.empty?
				  returnValue = default
			  end
		  rescue
			  returnValue = inVariable
		  end
	  end
	  return returnValue
  end #end method set_default
  
  def sanitize_js_type(inJSType)
	  inJSType = inJSType.truncate
	  if (inJSType == 0.0) || (inJSType == 1.0) || (inJSType == 2.0) || 
	      (inJSType == 3.0) || (inJSType == 4.0)
		  inJSType
	  else
		  "Error: Invalid Joint Annuity Type"
	  end
  end #end method sanitize_js_type
  
  def sanitize_js_pct(inJSPct)
	  if inJSPct < 0.0
		  inJSPct = 0.0
	  end
	  if inJSPct > 1.0 && inJSPct < 2.0
		  inJSPct = 1.0
	  end
	  if inJSPct > 100.0
		  inJSPct = 100.0
	  end
	  if inJSPct > 1.0
		  inJSPct / 100.0
	  else
		  inJSPct
	  end
  end #end method sanitize_js_pct
end #end module GenFactor