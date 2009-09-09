module GenFactor
  LX_ZERO = 1000000
  SEGMENT_TWO = 5.0
  SEGMENT_THREE = 20.0
  TABLE_END = 120.0

  def sanitize_age(age)
    ((age * 12.0).round / 12.0)
  end # end method sanitize_age
  
  def sanitize_interest(int)
	  int < 1.0 ? int : (int / 100.0)
  end #end method sanitize_interest
  
  def round_factor(factor,sigFigs)
	  (factor * (10.0**sigFigs)).round / (10.0**sigFigs)
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
	  returnValue
  end #end method validate_float   
  
  def set_default(inVariable,default)
	  if nil == inVariable
		  default
	  else	
		  begin
			  if inVariable.empty?
				  default
			  end
		  rescue
			  inVariable
		  end
	  end
  end #end method set_default
  
  def sanitize_js_type(inJSType)
	  inJSType = inJSType.truncate
	  if (0.0 == inJSType) or (1.0 == inJSType) or (2.0 == inJSType) or 
	      (3.0 == inJSType) or (4.0 == inJSType)
		  inJSType
	  else
		  "Error: Invalid Joint Annuity Type"
	  end
  end #end method sanitize_js_type
  
  def sanitize_js_pct(inJSPct)
	  if inJSPct < 0.0
		  0.0
	  end
	  if inJSPct > 1.0 and inJSPct < 2.0
		  1.0
	  end
	  if inJSPct > 100.0
		  100.0
	  end
	  if inJSPct > 1.0
		  inJSPct / 100.0
	  else
		  inJSPct
	  end
  end #end method sanitize_js_pct
end #end module GenFactor