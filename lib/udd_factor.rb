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
  # @return [float] Present Value Factor
  #
  # @todo protect this method
  #
  # @since version 1.0.0
  ##
  def calculate_present_value()
    returnValue = singlePV = spousePV = jointPV = time = payment = 0.0
    age = @immediate_age
    dAge = @commencement_age
    lxZero = lxZeroSpouse = LX_ZERO
    sAge = @secondary_age
    jointCalc = @joint_survivor_type

    mortalityDiscount = mortalityDiscountSpouse = mortalityDiscountJoint = 1.0

    lX = lxZero
    lXSpouse = lxZeroSpouse

    dX = calculate_dx(0.0,lX,age.truncate,@primary_mortality)
    dXSpouse = calculate_dx(0.0,lXSpouse,sAge.truncate,@secondary_mortality)

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
          interestRate = @interest_segment_a
        elsif SEGMENT_THREE > monthlyTime
          interestRate = @interest_segment_b
        else
          interestRate = @interest_segment_c
        end
      
        if age < dAge
          payment = 0.0
        else
          payment = (1.0/12.0)
        end
      
        if @temporary_period > 0.0
          if age >= (@temporary_period + dAge)
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

        dX = calculate_dx(dX,lX,age,@primary_mortality)
        dXSpouse = calculate_dx(dXSpouse,lXSpouse,sAge,@secondary_mortality)
        if ((nil != @certain_period) and age >= (dAge + @certain_period) || age <= dAge) or (nil == @certain_period)
            mortalityDiscount = GenFactor::calculate_discount(lX, lxZero)
            mortalityDiscountSpouse = GenFactor::calculate_discount(lXSpouse,lxZeroSpouse)
            mortalityDiscountJoint = mortalityDiscount * mortalityDiscountSpouse
        end
      
      end #end while 0.0 < lX
    end #end if lx = 0.0
  
    returnValue = calculate_joint_factor(singlePV,spousePV,jointPV,@joint_survivor_type,@joint_survivor_percent)
    round_factor(returnValue,@rounding)
  end 
  module_function :calculate_present_value


  ##
  # Validates input parameters then generates a Present Value Factor.
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
			  calculate_present_value
		  else
			  true
		  end #if outputType is 0
	  
	  else #errors is not empty
      @errors
	  end #if errors.empty?
  end
  
  ##
  # Validates a single field and adds to the error messages if it is invalid.
  # 
  # @param [float] age - The value to be validated
  # @param [String] errorMessage - Error messages to be added if an error is raised
  # @param [float] radix - 1.0 for ages, 2.0 for interests, 3.0 for js_type, 4.0 for js_pct, 5 for rounding validation
  #
  # @since 2.0.0
  ## 
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
  
  ##
  # Validates the mortality tables for potential errors
  #
  # @raise [Non-Array] - If the Mortality table isn't an array
  # @raise [InvalidFloat] - If the table has non-numeric fields
  # @raise [InvalidEnd] - If the last row does not have a q(x) = 1.0
  #
  # @since version 2.0.0
  ##
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
  
  ##
  # Sets all the instance variables to default values
  #
  # @since version 2.0.0
  ##
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
  
  ##
  # Validates all the instance variables to ensure a calculation can be run
  #
  # @since version 2.0.0
  ##
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
  
  ##
  # Validates the logic errors that can occur and a calculation shouldn't take place.
  #
  # @since version 2.0.0
  ##
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