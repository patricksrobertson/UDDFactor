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
  # @param [Array] mortality - Mortality table for q(x) lookup
  # @param [0.0-1.0] seg1 - Segment 1: The first segment interest rate.
  # @param [0.0-1.0] seg2 - Segment 2: The second segment interest rate.
  # @param [0.0-1.0] seg3 - Segment 3: The third segment interest rate.  
  # @param certain - Certain Period: The number of years that the payment is guaranteed.
  # @param temp - Temporary Period: The number of years years after the commencement age 
  #                       the payments will be calculated.
  # @param rounding - Rounding: The number of significant figures to round.
  # @param [Array] spMortality - Mortality table for the q(x) lookup for the secondary beneficiary.
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
  def calculate_present_value(ages,rates,periods,mortality,spMortality)
  
    #first load the age parameters in
    immAge = ages[0]
    defAge = ages[1]
    spouseAge = ages[2]
    js_type = ages[3]
    js_pct = ages[4]
  
    #now the interest rates
    seg1 = rates[0]
    seg2 = rates[1]
    seg3 = rates[2]
  
    #finally the misc functions
    certain = periods[0]
    temp = periods[1]
    rounding = periods[2]
                              
    returnValue = singlePV = spousePV = jointPV = time = payment = 0.0
    age = immAge
    dAge = defAge
    lxZero = lxZeroSpouse = LX_ZERO
    sAge = spouseAge
    jointCalc = js_type

    mortalityDiscount = mortalityDiscountSpouse = mortalityDiscountJoint = 1.0

    lX = lxZero
    lXSpouse = lxZeroSpouse

    dX = calculate_dx(0.0,lX,age.truncate,mortality)
    dXSpouse = calculate_dx(0.0,lXSpouse,sAge.truncate,spMortality)

    lX = calculate_initial_lx(lX,dX,age)
    lxZero = lX

    lXSpouse = calculate_initial_lx(lXSpouse,dXSpouse,sAge)
    lxZeroSpouse = lXSpouse

    if 0.0 == lX
      retVal = 0.0 #everyone is already dead yo.
    else
      jointCalculationValid = false
      if jointCalc > 0.0 and lXSpouse > 0.0 
        jointCalculationValid = true
      end
      while (lX > 0.0) or (jointCalculationValid)
        monthlyTime = time / 12.0
        if SEGMENT_TWO > monthlyTime
          interestRate = seg1
        elsif SEGMENT_THREE > monthlyTime
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
      
        singlePV += GenFactor::unit_payment(mortalityDiscount,interestRate,time,payment)
        if jointCalc > 0.0
          sAge = add_month(sAge)
          if lXSpouse > 0.0
            spousePV += GenFactor::unit_payment(mortalityDiscountSpouse,interestRate,time,payment)
            jointPV += GenFactor::unit_payment(mortalityDiscountJoint,interestRate,time,payment)
          else
            jointCalculationValid = false
          end
        end
      
        time += 1.0
        age = add_month(age)

        lX = lX - dX
        lXSpouse = lXSpouse - dXSpouse

        dX = calculate_dx(dX,lX,age,mortality)
        dXSpouse = calculate_dx(dXSpouse,lXSpouse,sAge,mortality)
        if ((nil != certain) and age >= (dAge + certain) || age <= dAge) or (nil == certain)
            mortalityDiscount = GenFactor::calculate_discount(lX, lxZero)
            mortalityDiscountSpouse = GenFactor::calculate_discount(lXSpouse,lxZeroSpouse)
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
  # @param [Array] spMortality - Mortality table to fetch q(x) from for the secondary beneficiary.  Defaults 
  #                             to the primary mortality table.
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
  def generate_factor()
	  #set default blank input items
    self.default_values
  
	  #check to make sure we can do the calculation first
    self.validation
  	#now check for logical errors
  	self.validate_logic_errors
  	
	  if @errors.empty?
		  if 0 == @output_type
			  calculate_present_value([@immediate_age,@commencement_age,@secondary_age,@joint_survivor_type,@joint_survivor_percent],
											          [@interest_segment_a,@interest_segment_b,@interest_segment_c],
											          [@certain_period,@temporary_period,@rounding],
			                          @primary_mortality,@secondary_mortality)
		  else
			  true
		  end #if outputType is 0
	  
	  else #errors is not empty
      @errors
	  end #if errors.empty?
  end

  def validate_single_field(age,errorMessage,radix)
    begin 
      case radix
        when 1.0
	        GenFactor::sanitize_age(Float(age)) 
	      when 2.0
	        GenFactor::sanitize_interest(Float(age))
	      when 3.0
	        GenFactor::sanitize_js_type(Float(age))
        when 4.0
          jsPct = GenFactor::sanitize_js_pct(Float(age))
        when 5.0
          Float(age)
      end    
	  rescue
      self.append_error(errorMessage)
	  end
  end
  
  def validate_mortality(mortality,type)  
		unless mortality.is_a? Array
		  errorString = type + " Mortality: Mortality Table must be an array"
		  self.append_error(errorString)
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
        self.append_error(errorString)
      else
        unless (mortality[0][0] == 0.0) and (mortality[0][1] == 0.0)
          errorString = type + " Mortality: Invalid mortality table format: first row is not 0.0,0.0"
          self.append_error(errorString)
        end
        unless mortality[-1][1] == 1.0
          errorString = type + " Mortality: Invalid mortality table format: last row does not have a q(x) of 1.0"
         self.append_error(errorString)
        end        
      end
		end   
  end  
  
  def default_values()
	  @immediate_age = GenFactor::set_default(@immediate_age,@commencement_age)
	  @secondary_age = GenFactor::set_default(@secondary_age,0.0)
	  @joint_survivor_type = GenFactor::set_default(@joint_survivor_type,0.0)
	  @joint_survivor_percent = GenFactor::set_default(@joint_survivor_percent,0.0)
	  @primary_mortality = GenFactor::set_default(@primary_mortality,MortalityTable::PPA2009)
	  @secondary_mortality = GenFactor::set_default(@secondary_mortality,@primary_mortality)
	  @interest_segment_b = GenFactor::set_default(@interest_segment_b,@interest_segment_a)
	  @interest_segment_c = GenFactor::set_default(@interest_segment_c,@interest_segment_a)
	  @certain_period = GenFactor::set_default(@certain_period,0.0)
	  @temporary_period = GenFactor::set_default(@temporary_period,0.0)
	  @rounding = GenFactor::set_default(@rounding,12.0)
	  @output_type = GenFactor::set_default(@output_type,0.0)
  end
  
  def validation()
	  @immediate_age = validate_single_field(@immediate_age,"Immediate age cannot be converted into a number",1.0)
	  @commencement_age = validate_single_field(@commencement_age,"Commencement age cannot be converted into a number",1.0)
	  @secondary_age = validate_single_field(@secondary_age,"Spousal age cannot be converted into a number",1.0)
	  @joint_survivor_type = validate_single_field(@joint_survivor_type,"JS Type cannot be converted into a number",3.0)
    @joint_survivor_percent = validate_single_field(@joint_survivor_percent,"JS percent cannot be converted into a number",4.0)
    validate_mortality(@primary_mortality,"Primary")
    validate_mortality(@secondary_mortality,"Secondary")  
		@interest_segment_a = validate_single_field(@interest_segment_a,"Interest segment A cannot be converted into a number",2.0)
    @interest_segment_b = validate_single_field(@interest_segment_b,"Interest segment B cannot be converted into a number",2.0)
    @interest_segment_c = validate_single_field(@interest_segment_c,"Interest segment C cannot be converted into a number",2.0)    
    @certain_period = validate_single_field(@certain_period,"Certain period cannot be converted into a number",1.0)
    @temporary_period = validate_single_field(@temporary_period,"Temporary period cannot be converted into a number",1.0)
    @rounding = validate_single_field(@rounding,"Rounding cannot be converted into a number",5.0)  
  end
  
  def validate_logic_errors
    if @errors.empty?
		  if (@immediate_age < @commencement_age) && (@temporary_period > 0.0)
			  self.append_error("Error: Deferred Calculation with a Temporary Period")	
		  end	  
		  if (@immediate_age > @commencement_age)
        self.append_error("Error: Commencement age must be greater than or equal to immediate age")				  
		  end	  
	  end #if errors.empty?
	end
end