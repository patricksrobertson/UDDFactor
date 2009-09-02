module UDDFactor
include GenFactor
include MortalityTable

  def calculate_present_value(immAge,defAge,spouseAge,js_type,js_pct,seg1,seg2,seg3,certain,temp,rounding)
	returnValue = 0.0
    singlePV = 0.0
	spousePV = 0.0
	jointPV = 0.0
	time = 0.0
	payment = 0.0
	age = immAge
	dAge = defAge
	lxZero = LX_ZERO
	lxZeroSpouse = LX_ZERO
	sAge = spouseAge
	jointCalc = js_type
	
	mortalityDiscount = 1.0
	mortalityDiscountSpouse = 1.0
	mortalityDiscountJoint = 1.0
	
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
			if jointCalc > 0.0 && lXSpouse > 0.0
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
		end
	end
    #return round_factor(singlePV,rounding)
	returnValue = calculate_joint_factor(singlePV,spousePV,jointPV,js_type,js_pct)
	return round_factor(returnValue,rounding)
	
  end
  module_function :calculate_present_value
  
  def calculate_qx(age)
    retVal = 1.0
    age = age.truncate
		max_age = PPA2009[-1][0]
		if age > max_age
			retVal = PPA2009[-1][1]
		else
			retVal = PPA2009[age][1]
		end
		return retVal
  end 
  module_function :calculate_qx
  
  def unit_payment(mort_disc, interest, numberOfMonths,payment)
	return (mort_disc * payment) / ((1.0 + interest) ** (numberOfMonths / 12.0))
  end
  module_function :unit_payment
  	
  def generate_factor(immediateAge=0.0,commencementAge=65.0,spAge=0.0,
					 jsType=0.0,jsPct=0.0,mortality=MortalityTable::PPA2009,
					 intSegmentA=5.0,intSegmentB=0.0,intSegmentC=0.0,certainPeriod=0.0,
					 tempPeriod=0.0,rounding=12.0)
	errors = []
	immediateCalculation = 0.0
	jointCalculation = 0.0
	
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
	GenFactor::validate_float(immediateAge) != nil ?  errors << "Immediate Age: " + GenFactor::validate_float(immediateAge) : 
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
	end
	if errors.empty?
	#now check for logical errors
		if (immediateAge < commencementAge) && (tempPeriod > 0.0)
			errors << "Error: Deferred Calculation with a Temporary Period"
		end
		if (immediateAge > commencementAge)
			errors << "Error: Commencement age must be greater than or equal to immediate age"
		end
	end
	if errors.empty?
		#return [immediateAge,commencementAge, spAge, intSegmentA, intSegmentB, intSegmentC, certainPeriod,tempPeriod,rounding]
		return calculate_present_value(immediateAge,commencementAge,spAge,jsType,jsPct,
									   intSegmentA,intSegmentB,intSegmentC,certainPeriod,
									   tempPeriod,rounding)
	else
		return errors
	end
  end
  module_function :generate_factor
  
  def calculate_dx(inDX,inLX, age)
	returnValue = inDX
	if age == age.truncate
		returnValue = (inLX * calculate_qx(age)) / 12.0
	end
	return returnValue
  end
  def calculate_initial_lx(inLX,inDX,age)
	returnValue = inLX
	
	if age != age.truncate
		monthsProrate = ((age - age.truncate) * 12.0).round
		returnValue = inLX - (inDX * monthsProrate)
	end
	
	return returnValue
  end
  def calculate_discount(inLX,inLXZero)
	return Float(inLX) / Float(inLXZero)
  end
  
  def add_month(age)
	return GenFactor::sanitize_age((age + (1.0/12.0)))
  end
  def calculate_joint_factor(singlePV,spousePV,jointPV,js_type,js_pct)
	returnValue = 0.0
	if js_type == 0.0
		returnValue = singlePV
	elsif js_type == 1.0
		returnValue = singlePV + (js_pct * (spousePV - jointPV))
	elsif js_type == 2.0
		returnValue = (js_pct * singlePV) + (js_pct * spousePV) + ((1.0-(2.0* js_pct)) * jointPV)
	elsif js_type == 3.0
		returnValue = singlePV + js_pct * singlePV * (spousePV - jointPV) / jointPV
	elsif js_type == 4.0
		returnValue = jointPV
	end
	return returnValue
  end
end
	
	
	