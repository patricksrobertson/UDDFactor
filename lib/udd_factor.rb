module UDDFactor
include GenFactor
include MortalityTable

  def calculate_present_value(immAge,defAge,seg1,seg2,seg3,certain,temp,rounding)
    retVal = 0.0
	time = 0.0
	payment = 0.0
	age = immAge
	dAge = defAge
	lxZero = LX_ZERO
	
	mortalityDiscount = 1.0
	lX = lxZero
	dX = (lX * calculate_qx(age)) / 12.0
	if age != age.truncate
		monthsProrate = ((age - age.truncate) * 12.0).round
		lX = lX - (dX * monthsProrate)
		lxZero = lX
	end
	
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
				if age > (temp + dAge)
					payment = 0.0
				end
			end
			unit_payment(mortalityDiscount,interestRate,time,payment)
			retVal += unit_payment(mortalityDiscount,interestRate,time,payment)
			time += 1.0
			age = age + (1.0/12.0)
			age = sanitize_age(age)
			#only need to call this for a new whole age
			lX = lX - dX
			if age.truncate == age
				dX = (lX * calculate_qx(age)) / 12.0
			end
			if nil != certain
				if age >= (dAge + certain)
					mortalityDiscount = lX / lxZero
				end
			else
				mortalityDiscount = lX / lxZero
			end
		end
	end
    return round_factor(retVal,rounding)
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
					 mortality=MortalityTable::PPA2009,intSegmentA=5.0,
					 intSegmentB=0.0,intSegmentC=0.0,certainPeriod=0.0,
					 tempPeriod=0.0,rounding=12.0)
	errors = []
	immediateCalculation = 0.0
	jointCalculation = 0.0
	
	#set default blank input items
	immediateAge = set_default(immediateAge,commencementAge)
	spAge = set_default(spAge,0.0)
	mortality = set_default(mortality,MortalityTable::PPA2009)
	intSegmentB = set_default(intSegmentB,intSegmentA)
	intSegmentC = set_default(intSegmentC,intSegmentA)
	certainPeriod = set_default(certainPeriod,0.0)
	tempPeriod = set_default(tempPeriod,0.0)
	rounding = set_default(rounding,12.0)
	
	#check to make sure we can do the calculation first
	validate_float(immediateAge) != nil ?  errors << "Immediate Age: " + validate_float(immediateAge) : 
	validate_float(commencementAge) != nil ? errors << "Commencement Age: " + validate_float(commencementAge) :
	validate_float(intSegmentA) != nil ? errors << "Interest Segment A: " + validate_float(intSegmentA) :
	validate_float(spAge) != nil ? errors << "Spousal Age: " + validate_float(spAge) :
	#errors << validate_mortality(mortality) #not implemented yet
	validate_float(intSegmentB) != nil ? errors << "Interest Segment B: " + validate_float(intSegmentB) :
	validate_float(intSegmentC) != nil ? errors << "Interest Segment C: " + validate_float(intSegmentC) :
	validate_float(certainPeriod) != nil ? errors << "Certain Period: " + validate_float(certainPeriod) : 
	validate_float(tempPeriod) != nil ? errors << "Temporary Period: " + validate_float(tempPeriod) : 
	validate_float(rounding) != nil ? errors << "Rounding: " + validate_float(rounding) : 

	if errors.empty?
		#agjust ages/periods to 1/12th of a year, make sure interest rates are grrrrreat!
		immediateAge = sanitize_age(Float(immediateAge))
		commencementAge = sanitize_age(Float(commencementAge))
		spAge = sanitize_age(Float(spAge))
		intSegmentA = sanitize_interest(Float(intSegmentA))
		intSegmentB = sanitize_interest(Float(intSegmentB))
		intSegmentC = sanitize_interest(Float(intSegmentC))
		certainPeriod = sanitize_age(Float(certainPeriod))
		tempPeriod = sanitize_age(Float(tempPeriod))
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
		return calculate_present_value(immediateAge,commencementAge,intSegmentA,
									   intSegmentB,intSegmentC,certainPeriod,
									   tempPeriod,rounding)
	else
		return errors
	end
  end
  module_function :generate_factor
end
	
	
	