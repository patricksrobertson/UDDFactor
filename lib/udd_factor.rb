module UDDFactor
include GenFactor
include MortalityTable
 
  def calculate_present_value(immAge,defAge,spouseAge,js_type,js_pct,seg1,seg2,seg3,certain,temp,rounding)
    returnValue, singlePV, spousePV, jointPV, time, payment = 0.0
    age = immAge
    dAge = defAge
    lxZero, lxZeroSpouse = LX_ZERO
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
 
  end #end method calculate_present_value
  module_function :calculate_present_value
  
  def calculate_qx(age)
    age = age.truncate
    max_age = PPA2009[-1][0]
    if age > max_age
      PPA2009[-1][1]
    else
      PPA2009[age][1]
    end
  end #end method calculate_qx
  
  def unit_payment(mort_disc, interest, numberOfMonths,payment)
    (mort_disc * payment) / ((1.0 + interest) ** (numberOfMonths / 12.0))
  end # end method unit_payment
  
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
	  GenFactor::validate_float(immediateAge) != nil ? errors << "Immediate Age: " + GenFactor::validate_float(immediateAge) :
	  GenFactor::validate_float(commencementAge) != nil ? errors << "Commencement Age: " + GenFactor::validate_float(commencementAge) :
	  GenFactor::validate_float(intSegmentA) != nil ? errors << "Interest Segment A: " + GenFactor::validate_float(intSegmentA) :
	  GenFactor::validate_float(spAge) != nil ? errors << "Spousal Age: " + GenFactor::validate_float(spAge) :
	  GenFactor::validate_float(jsType) != nil ? errors << "Joint Factor Type: " + GenFactor::validate_float(jsType) :
	  GenFactor::validate_float(jsPct) != nil ? errors << "Joint Factor Percent: " + GenFactor::validate_float(jsPct) :
	  #errors << validate_mortality(mortality) #not implemented yet
	  GenFactor::validate_float(intSegmentB) != nil ? errors << "Interest Segment B: " + GenFactor::validate_float(intSegmentB) :
	  GenFactor::validate_float(intSegmentC) != nil ? errors << "Interest Segment C: " + GenFactor::validate_float(intSegmentC) :
	  GenFactor::validate_float(certainPeriod) != nil ? errors << "Certain Period: " + GenFactor::validate_float(certainPeriod) :
	  GenFactor::validate_float(tempPeriod) != nil ? errors << "Temporary Period: " + GenFactor::validate_float(tempPeriod) :
	  GenFactor::validate_float(rounding) != nil ? errors << "Rounding: " + GenFactor::validate_float(rounding) :
 
	  if errors.empty?
		  #agjust ages/periods to 1/12th of a year, make sure interest rates are grrrrreat!
		  immediateAge = GenFactor::sanitize_age(Float(immediateAge))
		  commencementAge = GenFactor::sanitize_age(Float(commencementAge))
		  spAge = GenFactor::sanitize_age(Float(spAge))
		  jsType = GenFactor::sanitize_js_type(Float(jsType))
		  jsPct = GenFactor::sanitize_js_pct(Float(jsPct))
		  intSegmentA = GenFactor::sanitize_interest(Float(intSegmentA))
		  intSegmentB = GenFactor::sanitize_interest(Float(intSegmentB))
		  intSegmentC = GenFactor::sanitize_interest(Float(intSegmentC))
		  certainPeriod = GenFactor::sanitize_age(Float(certainPeriod))
		  tempPeriod = GenFactor::sanitize_age(Float(tempPeriod))
		  rounding = Float(rounding)
	  end #if errors.empty?
	  
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
  end # end method generate_factor
  module_function :generate_factor
  
  def calculate_dx(inDX,inLX, age)
    if age == age.truncate
      (inLX * calculate_qx(age)) / 12.0
    else
      inDX
    end
  end #end method calculate_dx
  
  def calculate_initial_lx(inLX,inDX,age)
    if age != age.truncate
      monthsProrate = ((age - age.truncate) * 12.0).round
      inLX - (inDX * monthsProrate)
    else
      inLX
    end
  end #end method calculate_initial_lx

  def calculate_discount(inLX,inLXZero)
    Float(inLX) / Float(inLXZero)
  end #end method calculate_discount
  
  def add_month(age)
    GenFactor::sanitize_age((age + (1.0/12.0)))
  end #end method add_month
  
  def calculate_joint_factor(singlePV,spousePV,jointPV,js_type,js_pct)
    case js_type
      when 0.0
        singlePV
      when 1.0
        singlePV + (js_pct * (spousePV - jointPV))
      when 2.0
        (js_pct * singlePV) + (js_pct * spousePV) + ((1.0-(2.0* js_pct)) * jointPV)
      when 3.0
        singlePV + js_pct * singlePV * (spousePV - jointPV) / jointPV
      when 4.0
        jointPV
    else
        singlePV
    end
  end #end method calculate_joint_factor
  
end #end module udd_factor