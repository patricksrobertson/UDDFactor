##
# @author Patrick Robertson
# @ version 1.0.0
#
# UDDFactor is a clase that generates monthly annuity factors using the UDD methodology required
# by PPA legislation.
##

module UDDFactor
include GenFactor
include MortalityTable

  ##
  # Calculates the present value of each unit payment and sums them to create a factor.
  # This method lacks the validation of generate_factor.  {#generate_factor} should be called instead.
  #
  # @param immAge - Immediate Age: The age to start deferral calculations from.
  # @param defAge - Deferred Age: The commencment or deferred age.
  # @param spouseAge - Spousal Age: The spousal commencement age.
  # @param [0.0,1.0,2.0,3.0,4.0] js_type - Joint and Survivor Type: See {#calculate_joint_factor} for valid values
  # @param [0.0-1.0] js_pct - Joint and Survivor Percent: Value between 0.0 and 1.0 that represents the amount
  #                         a survivor will receive.
  # @param [0.0-1.0] seg1 - Segment 1: The first segment interest rate.
  # @param [0.0-1.0] seg2 - Segment 2: The second segment interest rate.
  # @param [0.0-1.0] seg3 - Segment 3: The third segment interest rate.  
  # @param certain - Certain Period: The number of years that the payment is guaranteed.
  # @param temp - Temporary Period: The number of years years after the commencement age 
  #                       the payments will be calculated.
  # @param rounding - Rounding: The number of significant figures to round.
  #
  # @return [float] Present Value Factor
  #
  # @example A 47% percent joint and survivor factor.
  # "calculate_present_value(65.0,65.0,61.0,2.0,0.47,0.0544,0.0544,0.0544,0.0,0.0,6.0)"
  #
  # @todo protect this method
  #
  # @since version 1.0.0
  ##
  def calculate_present_value(immAge,defAge,spouseAge,js_type,js_pct,seg1,seg2,seg3,certain,temp,rounding)
    returnValue = singlePV = spousePV = jointPV = time = payment = 0.0
    age = immAge
    dAge = defAge
    lxZero = lxZeroSpouse = LX_ZERO
    sAge = spouseAge
    jointCalc = js_type
 
    mortalityDiscount, mortalityDiscountSpouse, mortalityDiscountJoint = 1.0
 
    lX = lxZero
    lXSpouse = lxZeroSpouse
 
    dX = calculate_dx(0.0,lX,age.truncate)
    dXSpouse = calculate_dx(0.0,lXSpouse,sAge.truncate)
 
    lX = calculate_initial_lx(lX,dX,age)
    lxZero = lX
 
    lXSpouse = calculate_initial_lx(lXSpouse,dXSpouse,sAge)
    lxZeroSpouse = lX
 
    if 0.0 == lX
      retVal = 0.0 #everyone is already dead yo.
    else
      while 0.0 < lX
        if SEGMENT_TWO > (time / 12.0)
          interestRate = seg1
        elsif SEGMENT_THREE > (time / 12.0)
          interestRate = seg2
        else
          interestRate = seg3
        end
        
        if age < dAge
          payment = 0.0
        else
          payment = (1.0/12.0)
        end
        
        if temp > 0.0
          if age >= (temp + dAge)
            payment = 0.0
          end
        end
        
        singlePV += unit_payment(mortalityDiscount,interestRate,time,payment)
        if jointCalc > 0.0 and lXSpouse > 0.0
          spousePV += unit_payment(mortalityDiscountSpouse,interestRate,time,payment)
          jointPV += unit_payment(mortalityDiscountJoint,interestRate,time,payment)
          sAge = add_month(sAge)
        end
        
        time += 1.0
        age = add_month(age)
 
        lX = lX - dX
        lXSpouse = lXSpouse - dXSpouse
 
        dX = calculate_dx(dX,lX,age)
        dXSpouse = calculate_dx(dXSpouse,lXSpouse,sAge)
        if nil != certain
          if age >= (dAge + certain) || age <= dAge
            mortalityDiscount = calculate_discount(lX, lxZero)
            mortalityDiscountSpouse = calculate_discount(lXSpouse,lxZeroSpouse)
            mortalityDiscountJoint = mortalityDiscount * mortalityDiscountSpouse
          end
        else
          mortalityDiscount = calculate_discount(lX, lxZero)
          mortalityDiscountSpouse = calculate_discount(lXSpouse,lxZeroSpouse)
          mortalityDiscountJoint = mortalityDiscount * mortalityDiscountSpouse
        end
        
      end #end while 0.0 < lX
    end #end if lx = 0.0
    
    returnValue = calculate_joint_factor(singlePV,spousePV,jointPV,js_type,js_pct)
    
    round_factor(returnValue,rounding)
 
  end 
  module_function :calculate_present_value

  
  ##
  # Validates input parameters then generates a Present Value Factor.
  #
  # @example Single Life Annuity Factor
  # "generate_factor(,65.0,,,,MortalityTable::PPA2010,5.44,,,,,)"
  #
  # @param [nil,float] immediateAge - Beginning age for deferred calculations.  Defaults to commencementAge.
  # @param [float] commencementAge - Age that payment begins.  This parameter is required.
  # @param [nil,float] spAge - Spouse commencement age.
  # @param [nil,float] jsType - Joint and Survivor factor type.  Defaults to 0.0
  # @param [nil,float] jsPct - Joint and Survivor percentage.  Defaults to 0.0.
  # @param [Array] mortality - Mortality Table used to fetch q(x) from.  Defaults to {MortalityTable::PPA2009}
  # @param [float] intSegmentA - First interest rate segment.  This parameter is required.
  # @param [nil,float] intSegmentB - Second interest rate segment.  Defaults to intSegmentA.
  # @param [nil,float] intSegmentC - Third interest rate segment.  Defaults to intSegmentA.  
  # @param [nil,float] certainPeriod - Guaranteed payment period. Defaults to 0.0.  
  # @param [nil,float] tempPeriod - Temporary factor period.  Defaults to 0.0.
  # @param [nil,float] rounding - Digits to round to.  Defaults to 12.0.
  # @param [nil,float] outputType - If set to 0, runs a factor as normal.  Anything else is validation mode.
  #                               Validation mode runs the checks, and outputs the error message without
  #                               running the {#calculate_present_value} method.
  #
  # @raise [InvalidFloat] if any input parameter cannot be converted to a float, it will produce an error.
  # @raise [DefTemp] if immediateAge < commencementAge and tempPeriod > 0, will throw an error.
  # @raise [ImmComm] if immediateAge > commencementAge, will throw an error.
  #
  # @todo Add in verbose mode.
  #
  # @return [float,string,true] If outputType = 0, outputs a present value factor or an error message.
  #                             If outputType =1 , outputs true or an error message.
  #
  # @since version 1.0.0   
  ##
  
  def generate_factor(immediateAge=0.0,commencementAge=65.0,spAge=0.0,
	                    jsType=0.0,jsPct=0.0,mortality=MortalityTable::PPA2009,
	                    intSegmentA=5.0,intSegmentB=0.0,intSegmentC=0.0,certainPeriod=0.0,
	                    tempPeriod=0.0,rounding=12.0,outputType=0.0)
	  errors = []
	  immediateCalculation, jointCalculation = 0.0
 
	  #set default blank input items
	  immediateAge = GenFactor::set_default(immediateAge,commencementAge)
	  spAge = GenFactor::set_default(spAge,0.0)
	  jsType = GenFactor::set_default(jsType,0.0)
	  jsPct = GenFactor::set_default(jsPct,0.0)
	  mortality = GenFactor::set_default(mortality,MortalityTable::PPA2009)
	  intSegmentB = GenFactor::set_default(intSegmentB,intSegmentA)
	  intSegmentC = GenFactor::set_default(intSegmentC,intSegmentA)
	  certainPeriod = GenFactor::set_default(certainPeriod,0.0)
	  tempPeriod = GenFactor::set_default(tempPeriod,0.0)
	  rounding = GenFactor::set_default(rounding,12.0)
 
	  #check to make sure we can do the calculation first
	  begin 
	    immediateAge = GenFactor::sanitize_age(Float(immediateAge)) 
	  rescue
	    errorString = "Immediate age cannot be converted into a number"
	    errors = GenFactor::append_error(errors,errorString)
	  end 
	  begin
	    commencementAge = GenFactor::sanitize_age(Float(commencementAge))  
	  rescue
	    errorString = "Commencement age cannot be converted into a number"
	    errors = GenFactor::append_error(errors,errorString)
	  end
	  begin
		  spAge = GenFactor::sanitize_age(Float(spAge))
		rescue
		  errorString = "Spousal age cannot be converted into a number"
		  errors = GenFactor::append_error(errors,errorString)	      
		end
		begin
		  jsType = GenFactor::sanitize_js_type(Float(jsType))
		rescue
		  errorString = "JS Type cannot be converted into a number"		
		  errors = GenFactor::append_error(errors,errorString)
		end
		#mortality validation time.  
		unless mortality.is_a? Array
		  errorString = "Mortality Table must be an array"
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
	      errorString = "Invalid mortality table format: cannot convert all elements to numbers"
        errors = GenFactor::append_error(errors,errorString)
      else
        unless (mortality[0][0] == 0.0) and (mortality[0][1] == 0.0)
          errorString = "Invalid mortality table format: first row is not 0.0,0.0"
          errors = GenFactor::append_error(errors,errorString)
        end
        unless mortality[-1][1] == 1.0
          errorString = "Invalid mortality table format: last row does not have a q(x) of 1.0"
          errors = GenFactor::append_error(errors,errorString)
        end        
      end
		end
		begin
		  jsPct = GenFactor::sanitize_js_pct(Float(jsPct))
		rescue
		  errorString = "JS percent cannot be converted into a number"		
		  errors = GenFactor::append_error(errors,errorString)		
		end
		begin
      intSegmentA = GenFactor::sanitize_interest(Float(intSegmentA))		  
    rescue
		  errorString = "Interest segment A cannot be converted into a number"		
		  errors = GenFactor::append_error(errors,errorString)      
		end
		begin
		  intSegmentB = GenFactor::sanitize_interest(Float(intSegmentB))
		rescue
		  errorString = "Interest segment B cannot be converted into a number"		
		  errors = GenFactor::append_error(errors,errorString)		  		  
		end
		begin
		  intSegmentC = GenFactor::sanitize_interest(Float(intSegmentC))
		rescue
		  errorString = "Interest segment C cannot be converted into a number"		
		  errors = GenFactor::append_error(errors,errorString)		  
		end
    begin
		  certainPeriod = GenFactor::sanitize_age(Float(certainPeriod))
		rescue
		  errorString = "Certain period cannot be converted into a number"		
		  errors = GenFactor::append_error(errors,errorString)		        
		end
		begin
		  tempPeriod = GenFactor::sanitize_age(Float(tempPeriod))
		rescue
		  errorString = "Temporary period cannot be converted into a number"		
		  errors = GenFactor::append_error(errors,errorString)		  		  
		end
		begin
		  rounding = Float(rounding)
		rescue
		  errorString = "Rounding cannot be converted into a number"		
		  errors = GenFactor::append_error(errors,errorString)		  
		end
	  
	  if errors.empty?
		  #now check for logical errors
		  if (immediateAge < commencementAge) && (tempPeriod > 0.0)
			  errors << "Error: Deferred Calculation with a Temporary Period"
		  end
		  
		  if (immediateAge > commencementAge)
			  errors << "Error: Commencement age must be greater than or equal to immediate age"
		  end
		  
	  end #if errors.empty?
	  
	  if errors.empty?
		  if 0 == outputType
			  calculate_present_value(immediateAge,commencementAge,spAge,jsType,jsPct,
											          intSegmentA,intSegmentB,intSegmentC,certainPeriod,
											          tempPeriod,rounding)
		  else
			  true
		  end #if outputType is 0
		  
	  else #errors is not empty
      errors
	  end #if errors.empty?
  end
  module_function :generate_factor
  
end