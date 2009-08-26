module UDDFactor

  LX_ZERO = 1000000
  SEGMENT_TWO = 5.0
  SEGMENT_THREE = 20.0
  TABLE_END = 120.0
  
  PPA2009 = [
  #age		q
  [0.0,		0],
  [1.0,		0.000372],
  [2.0,		0.000247],
  [3.0,		0.000196],
  [4.0,		0.000150],
  [5.0,		0.000137],
  [6.0,		0.000129],
  [7.0,		0.000123],
  [8.0,		0.000112],
  [9.0,		0.000108],
  [10.0,	0.000109],
  [11.0,	0.000112],
  [12.0,	0.000116],
  [13.0,	0.000122],
  [14.0,	0.000133],
  [15.0,	0.000143],
  [16.0,	0.000151],
  [17.0,	0.000161],
  [18.0,	0.000167],
  [19.0,	0.000171],
  [20.0,	0.000174],
  [21.0,	0.000179],
  [22.0,	0.000186],
  [23.0,	0.000197],
  [24.0,	0.000208],
  [25.0,	0.000222],
  [26.0,	0.000244],
  [27.0,	0.000253],
  [28.0,	0.000262],
  [29.0,	0.000276],
  [30.0,	0.000301],
  [31.0,	0.000348],
  [32.0,	0.000394],
  [33.0,	0.000438],
  [34.0,	0.000482],
  [35.0,	0.000525],
  [36.0,	0.000566],
  [37.0,	0.000604],
  [38.0,	0.000630],
  [39.0,	0.000657],
  [40.0,	0.000691],
  [41.0,	0.000729],
  [42.0,	0.000775],
  [43.0,	0.000826],
  [44.0,	0.000885],
  [45.0,	0.000940],
  [46.0,	0.000994],
  [47.0,	0.001054],
  [48.0,	0.001130],
  [49.0,	0.001215],
  [50.0,	0.001323],
  [51.0,	0.001423],
  [52.0,	0.001570],
  [53.0,	0.001764],
  [54.0,	0.001990],
  [55.0,	0.002346],
  [56.0,	0.002818],
  [57.0,	0.003243],
  [58.0,	0.003706],
  [59.0,	0.004206],
  [60.0,	0.004803],
  [61.0,	0.005576],
  [62.0,	0.006405],
  [63.0,	0.007444],
  [64.0,	0.008410],
  [65.0,	0.009508],
  [66.0,	0.010866],
  [67.0,	0.012108],
  [68.0,	0.013316],
  [69.0,	0.014742],
  [70.0,	0.016160],
  [71.0,	0.017803],
  [72.0,	0.019833],
  [73.0,	0.021968],
  [74.0,	0.024500],
  [75.0,	0.027315],
  [76.0,	0.030348],
  [77.0,	0.034204],
  [78.0,	0.038256],
  [79.0,	0.042806],
  [80.0,	0.047905],
  [81.0,	0.053861],
  [82.0,	0.060545],
  [83.0,	0.067380],
  [84.0,	0.075650],
  [85.0,	0.084660],
  [86.0,	0.094731],
  [87.0,	0.106954],
  [88.0,	0.119811],
  [89.0,	0.133578],
  [90.0,	0.148759],
  [91.0,	0.162589],
  [92.0,	0.178330],
  [93.0,	0.193878],
  [94.0,	0.207982],
  [95.0,	0.223718],
  [96.0,	0.236930],
  [97.0,	0.251111],
  [98.0,	0.265340],
  [99.0,	0.276338],
  [100.0,	0.286390],
  [101.0,	0.301731],
  [102.0,	0.313092],
  [103.0,	0.324542],
  [104.0,	0.335529],
  [105.0,	0.345501],
  [106.0,	0.353906],
  [107.0,	0.361363],
  [108.0,	0.368721],
  [109.0,	0.375772],
  [110.0,	0.382309],
  [111.0,	0.388123],
  [112.0,	0.393008],
  [113.0,	0.396754],
  [114.0,	0.399154],
  [115.0,	0.400000],
  [116.0,	0.400000],
  [117.0,	0.400000],
  [118.0,	0.400000],
  [119.0,	0.400000],
  [120.0,	1.000000]
  ]
    
  def annuity_certain(certain,seg1,seg2,seg3)
    retVal = 0.0
	retVal = annuity_certain_combined([certain,SEGMENT_TWO].min,seg1)
	if SEGMENT_TWO < certain 
		nil == seg2 ? seg2 = seg1 : seg2 = seg2
		retVal += annuity_certain_combined(SEGMENT_TWO,[certain,SEGMENT_THREE].min,seg2) 
	end
	if SEGMENT_THREE < certain 
		nil == seg3 ? seg3 = seg1 : seg3 = seg3
		retVal += annuity_certain_combined(SEGMENT_THREE,[certain,TABLE_END].min,seg3) 
	end
	return retVal
  end 
  module_function :annuity_certain 

  def calculate_present_value(immAge,defAge,seg1,seg2,seg3,certain,temp)
    retVal = 0.0
	age = sanitize_age(immAge)
	dAge = sanitize_age(defAge)
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
			mortalityDiscount = lX / lxZero
		end
	end
    return retVal
  end
  module_function :calculate_present_value
  	  
  def interest_discount(int_rate)
	int_rate = sanitize_interest(int_rate)
	return 1.0 / (1.0 + int_rate)
  end
  module_function :interest_discount
  
  def yearly_discount(int_disc)
	return 12.0 * (1.0 - (int_disc ** (1.0/12.0)))
  end
  module_function :yearly_discount
  
  def annuity_certain_combined(*args)
	retVal = nil
	if 2 == args.size
		certain = args[0]
		interest = args[1]
		
		int_disc = interest_discount(interest)
		year_disc = yearly_discount(int_disc)
		retVal = (1.0 - (int_disc ** certain)) / year_disc		
	elsif 3 == args.size
		min_certain = args[0]
		max_certain = args[1]
		interest = args[2]
		
		int_disc = interest_discount(interest)
		year_disc = yearly_discount(int_disc)
		retVal = ((int_disc ** min_certain) - (int_disc ** max_certain)) / year_disc		
	end
	
	return retVal
  end
  module_function :annuity_certain_combined
  
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
end
