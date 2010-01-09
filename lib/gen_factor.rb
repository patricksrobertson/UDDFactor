##
# @author Patrick Robertson
# @ version 1.0.0
#
# GenFactor contains some shared methods between UDDFactor and AnnuityCertain.
##

module GenFactor
  LX_ZERO = 1000000
  SEGMENT_TWO = 5.0
  SEGMENT_THREE = 20.0
  TABLE_END = 120.0

  ##
  # Rounds age to the nearest month
  # 
  # @since version 1.0.0
  ##
  def sanitize_age(age)
    ((age * 12.0).round / 12.0)
  end 
  
  ##
  # Ensures interest is in 0.0-1.0 format
  #
  # @since version 1.0.0
  ##
  def sanitize_interest(int)
	  int < 1.0 ? int : (int / 100.0)
  end 
  
  ##
  # Rounds given factor to the number of digits desired
  #
  # @since version 1.0.0
  ##
  def round_factor(factor,sigFigs)
	  (factor * (10.0**sigFigs)).round / (10.0**sigFigs)
  end 
  
  ##
  # Checks to see if the incoming variable can be converted to float.
  #
  # @return [error,float] - If the incoming variable can be converted to a float
  #                         it returns nil, otherwise it returns the error message.
  #
  # @since version 1.0.0
  ##
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
  end   
  
  ##
  # Decides whether a variable needs to be defaulted or not.
  #
  # @since version 1.0.0
  ##
  def set_default(inVariable,default)
	  if nil == inVariable
		  default
	  else	
			  if inVariable.empty?
				  default
			  else 
			    inVariable
			  end
	  end
  end 
  
  ##
  # Ensures the J&S type is a valid one.
  #
  # @since version 1.0.0
  ##
  def sanitize_js_type(inJSType)
	  inJSType = inJSType.truncate
	  if (0.0 == inJSType) or (1.0 == inJSType) or (2.0 == inJSType) or 
	      (3.0 == inJSType) or (4.0 == inJSType)
		  inJSType
	  else
		  "Error: Invalid Joint Annuity Type"
	  end
  end 
  
  ##
  # Ensures the J&S percentage is in 0.0-1.0 format and valid.
  #
  # @since version 1.0.0
  ##
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
  end 
 

  ##
  # Calculates the number people that will die at the current age.  Doesn't
  # recalculate unless the current age is an integer.
  #
  # @example
  # "calculate_dx(308.0,987343,56.083...)"
  #
  # @return [float] If the age is a whole integer age, will return a new amount of 
  #                 people that will die at that age.  Otherwise returns the input
  #                 age.
  #
  # @since version 1.0.0
  ##
  def calculate_dx(inDX,inLX,age,mortality)
    if age == age.truncate
      (inLX * calculate_qx(age,mortality)) / 12.0
    else
      inDX
    end
  end

  ## 
  # Retrieves the q(x) from the appropriate mortality table.
  #
  # @example 
  # "calculate_qx(55.0)"
  #
  # @return [float] q(x)
  #
  # @todo Add in additional mortality table support
  #
  # @since version 1.0.0
  ##
  def calculate_qx(age,mortality=MortalityTable::PPA2010)
    age = age.truncate
    max_age = mortality[-1][0]
    if age > max_age
      mortality[-1][1]
    else
      mortality[age][1]
    end
  end
 
  ## 
  # calculates amount of people alive at a given age.  If the age is a whole age,
  # it does nothing.  Otherwise it performs linear interporlation on the number of 
  # people that will die at the age.
  #
  # @example 
  # "calculate_initial_lx(1000000.0,360.0,55.083...)"
  #
  # @return [float] If age is whole integer age, lX.  Otherwise interpolated l(x).
  #
  # @since 1.0.0
  ##
  def calculate_initial_lx(inLX,inDX,age)
    if age != age.truncate
      monthsProrate = ((age - age.truncate) * 12.0).round
      inLX - (inDX * monthsProrate)
    else
      inLX
    end
  end
 
  ##
  # Calculates a single unit payment given a nPx, interest rate, time elapsed
  # and what period is being payed.
  #
  # @example
  # "unit_payment(0.99832,0.0544,12,0.833....)"
  #
  # @param [float] mort_disc - nPx at given time.
  # @param [float] interest - applicable interest rate
  # @param [float] numberOfMonths - the specific point in time for the calculation.
  # @param [float] payment - The amount being paid (1/12 or 0)
  #
  # @return [float] Unit payment.
  #
  # @since version 1.0.0
  ##
  def unit_payment(mort_disc, interest, numberOfMonths,payment)
    (mort_disc * payment) / ((1.0 + interest) ** (numberOfMonths / 12.0))
  end
 
  ## 
  # calculates the nPx value given an l(x) and l(0)
  #
  # @example 
  # "calculate_discount(999500.0,1000000.0)"
  # 
  # @return [float] nPx
  # 
  # @since version 1.0.0
  ##
  def calculate_discount(inLX,inLXZero)
    Float(inLX) / Float(inLXZero)
  end
 
  ##
  # Adds a month and then rounds to the nearest month.
  ##
  def add_month(age) 
    GenFactor::sanitize_age((age + (1.0/12.0)))
  end 
 
  ##
  # Given a primary, secondary, and joint present value, it will calculate SLA's,
  # normal J&S factors, "true" J&S factors, J&S factors with "pop-up", and Joint
  # annuities.
  #
  # @example J&S with "pop-up"
  # "calculate_joint_factor(12.2342,11.4421,9.3435,3.0,0.50)"
  #
  # @param [0.0,1.0,2.0,3.0,4.0] js_type - Determines the J&S type.  0- SLA, 1- normal J&S,
  #                                        2 - "true" J&S, 3 - J&S + pop-up, 4 - Joint Annuity.
  #
  # @return [float] Present value factor
  #
  # @since version 1.0.0
  ##
  def calculate_joint_factor(singlePV,spousePV,jointPV,js_type,js_pct)
    case js_type
      when 0.0
        singlePV
      when 1.0
        singlePV + js_pct * (spousePV - jointPV)
      when 2.0
        (js_pct * singlePV) + (js_pct * spousePV) + ((1.0-(2.0* js_pct)) * jointPV)
      when 3.0
        singlePV + js_pct * singlePV * (spousePV - jointPV) / jointPV
      when 4.0
        jointPV
    else
      singlePV
    end
  end

  ##
  # returns the interest discount
  # @since version 1.0.0
  ##	  
  def interest_discount(int_rate)
	  int_rate = sanitize_interest(int_rate)
	  1.0 / (1.0 + int_rate)
  end 
  
  ##
  # returns the yearly discount(this is a poor name for it)
  # @since version 1.0.0
  ##
  def yearly_discount(int_disc)
	  12.0 * (1.0 - (int_disc ** (1.0/12.0)))
  end

  ##
  # Adds the message onto the error string
  # @since version 1.0.1
  ##
  def append_error(error,msg)
    error.empty? ? error = msg : error << "\n" + msg + " "
    error
  end  
  def method_missing(method,*args)
    false
  end
  
  ##
  # Mortality validation functionality moved to a method since there are
  # primary and secondary mortality tables in 1.1.0
  # @since version 1.1.0
  ##
  
  def validate_mortality(mortality,errors,type)  
		unless mortality.is_a? Array
		  errorString = type + " Mortality: Mortality Table must be an array"
		  errors = GenFactor::append_error(errors,errorString)
		else
		  cErrorCount = 0.0
		  mortality.each do |ii|
		    begin
		      tempy = ii
		      tempo = Float(tempy[0])
		      tempsan = Float(tempy[1])
		    rescue
	          cErrorCount += 1.0
		    end
	    end
	    if cErrorCount > 0.0
	      errorString = type + " Mortality: Invalid mortality table format: cannot convert all elements to numbers"
        errors = GenFactor::append_error(errors,errorString)
      else
        unless (mortality[0][0] == 0.0) and (mortality[0][1] == 0.0)
          errorString = type + " Mortality: Invalid mortality table format: first row is not 0.0,0.0"
          errors = GenFactor::append_error(errors,errorString)
        end
        unless mortality[-1][1] == 1.0
          errorString = type + " Mortality: Invalid mortality table format: last row does not have a q(x) of 1.0"
          errors = GenFactor::append_error(errors,errorString)
        end        
      end
		end
		errors    
  end  
    
end