include GenFactor
include Mortality
module UDDFactor

  def calculate_present_value(immAge,defAge,seg1,seg2,seg3,certain=0.0,temp=0.0,rounding=12.0)
    retVal = 0.0
	age = sanitize_age(immAge)
	dAge = sanitize_age(defAge)
	if dAge > age
		temp = 0.0
	end
	time = 0.0
	payment = 0.0
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
				interestRate = sanitize_interest(seg1)
			elsif SEGMENT_THREE > (time / 12.0)
				if nil == seg2
					interestRate = sanitize_interest(seg1)
				else
					interestRate = sanitize_interest(seg2)
				end
			else
				if nil == seg3
					interestRate = sanitize_interest(seg1)
				else
					interestRate = sanitize_interest(seg3)
				end
			end
			if age < dAge
				payment = 0.0
			else
				payment = (1.0/12.0)
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
				if age >= (dAge + sanitize_age(certain))
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
end
