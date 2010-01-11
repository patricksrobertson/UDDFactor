require File.dirname(__FILE__) + '/test_helper.rb' 
#require '/../lib/udd_factor_2.rb'



class UDDFactorTest < Test::Unit::TestCase
  def test_nrd_sla
    #testing for an age 65 immediate factor
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    factor = test_factor.generate_factor
    assert_equal 11.435594641924, factor
  end
  
  def test_nrd_sla_2010
    #testing for an age 65 immediate factor for 2010
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2010
    test_factor.rounding = 6.0
    factor = test_factor.generate_factor       
    assert_equal 11.458457 , factor
  end  
  
  def test_nrd_sla_2011
    #testing for an age 65 immediate factor for 2011
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2011
    test_factor.rounding = 6.0
    factor = test_factor.generate_factor    
    assert_equal 11.481172 , factor 
  end  
  
  def test_nrd_sla_2012
    #testing for an age 65 immediate factor for 2012
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2012
    test_factor.rounding = 6.0
    factor = test_factor.generate_factor    
    assert_equal 11.503803 , factor
  end  
  
  def test_nrd_sla_2013
    #testing for an age 65 immediate factor for 2012
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2013
    test_factor.rounding = 6.0
    factor = test_factor.generate_factor    
    assert_equal 11.52628 , factor
  end  
  
  def test_def_nrd_sla
    #testing for a deferred factor to 65.
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 61.083
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    factor = test_factor.generate_factor    
    assert_equal 8.995730102955 , factor
  end
  
  def test_imm_certain
    #testing for a immediate certain factor
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 55.4166667
    test_factor.commencement_age = 55.417
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    test_factor.certain_period = 5.0
    factor = test_factor.generate_factor    
    assert_equal 13.938127140459 , factor
  end  
  
  def test_imm_temp
    #testing for a immediate temporary factor
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 55.4166667
    test_factor.commencement_age = 55.417
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    test_factor.temporary_period = 5.0
    factor = test_factor.generate_factor    
    assert_equal 4.390505351976 , factor
  end
  
  def test_imm_error
    #testing for an improper immediate age
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = "waffle"
    test_factor.commencement_age = 55.417
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    test_factor.certain_period = 5.0
    factor = test_factor.generate_factor    
    assert_equal "Immediate age cannot be converted into a number" , factor
  end  
  
  def test_imm_comm_error
    #testing for an improper immediate age + commencement age
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = "waffle"
    test_factor.commencement_age = "waffle"
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    test_factor.certain_period = 5.0
    factor = test_factor.generate_factor    
    assert_equal "Immediate age cannot be converted into a number" +
                 "\n" + "Commencement age cannot be converted into a number " , factor
  end  
  
  def test_sp_error
    #testing for an improper spouse age
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 55.417
    test_factor.secondary_age = "wrangle"
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    test_factor.certain_period = 5.0
    factor = test_factor.generate_factor    

    assert_equal "Spousal age cannot be converted into a number" , factor
  end  
  
  def test_js_type_error
    #testing for an improper js_type
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 55.417
    test_factor.joint_survivor_type = 'c'
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    test_factor.certain_period = 5.0
    factor = test_factor.generate_factor    
    assert_equal "JS Type cannot be converted into a number" , factor
  end  
  
  def test_mort_type_error
    #testing for an improper mortality type
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 55.417
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = "peanut"
    test_factor.certain_period = 5.0
    factor = test_factor.generate_factor    
    assert_equal "Primary Mortality: Mortality Table must be an array"+ "\n" + 
                          "Secondary Mortality: Mortality Table must be an array " , factor
  end  
  
  def test_mort_array_settings
    #testing whether the array has at least two columns, elements are all floats
    test_array = [ [0.0, 0.0],['cap','trade']]
    
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 55.417
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = test_array
    test_factor.certain_period = 5.0
    factor = test_factor.generate_factor
    assert_equal "Primary Mortality: Invalid mortality table format: cannot convert all elements to numbers" +
                          "\n" +
                          "Secondary Mortality: Invalid mortality table format: cannot convert all elements to numbers " , factor
  end
  
  def test_mort_array_first
    #testing whether the array's first row is 0.0,0.0
    test_array = [ [0.0, 0.435],[2.0,1.0]]
    
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 55.417
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = test_array
    test_factor.certain_period = 5.0
    factor = test_factor.generate_factor    
    assert_equal "Primary Mortality: Invalid mortality table format: first row is not 0.0,0.0" + "\n" +
                         "Secondary Mortality: Invalid mortality table format: first row is not 0.0,0.0 " , factor
  end  
  
  def test_mort_array_last
    #testing whether the array's last row has a q(x) of 1.0
    test_array = [ [0.0, 0.000],[1.0, 0.035]]
    
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 55.417
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = test_array
    test_factor.certain_period = 5.0
    factor = test_factor.generate_factor
    assert_equal "Primary Mortality: Invalid mortality table format: last row does not have a q(x) of 1.0" + 
                         "\n" +
                         "Secondary Mortality: Invalid mortality table format: last row does not have a q(x) of 1.0 " , factor
  end  
  
  def test_js_pct_error
    #testing for an improper js_pct
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 55.417
    test_factor.joint_survivor_percent = "waffles"
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    test_factor.certain_period = 5.0
    factor = test_factor.generate_factor
    assert_equal "JS percent cannot be converted into a number" , factor
  end  
  
  def test_int_a_error
    #testing for an improper interest segment A
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 55.417
    test_factor.interest_segment_a = "pancake"
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    test_factor.certain_period = 5.0
    factor = test_factor.generate_factor    
    assert_equal "Interest segment A cannot be converted into a number" , factor
  end  
  
  def test_int_b_error
    #testing for an improper interest segment B
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 55.417
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = "ice cream"
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    test_factor.certain_period = 5.0
    factor = test_factor.generate_factor    
    assert_equal "Interest segment B cannot be converted into a number", factor
  end  

  def test_int_c_error
    #testing for an improper interest segment C
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 55.417
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = "claw"
    test_factor.primary_mortality = MortalityTable::PPA2009
    test_factor.certain_period = 5.0
    factor = test_factor.generate_factor
    assert_equal "Interest segment C cannot be converted into a number" , factor
  end  
  
  def test_certain_error
    #testing for an improper certain period
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 55.417
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    test_factor.certain_period = "peanut"
    factor = test_factor.generate_factor
    assert_equal "Certain period cannot be converted into a number" , factor
  end  

  def test_temp_error
    #testing for an improper temp period
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 55.417
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    test_factor.temporary_period = "waff"
    factor = test_factor.generate_factor    
    assert_equal "Temporary period cannot be converted into a number", factor
  end
  
  def test_rounding_error
    #testing for an improper rounding
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 55.417
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    test_factor.certain_period = 5.0
    test_factor.rounding = "growl"
    factor = test_factor.generate_factor    
    assert_equal "Rounding cannot be converted into a number" , factor
  end  
  
  def test_default_imm
    #testing for defaulting immediate age
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = nil
    test_factor.commencement_age = 65.0
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    factor = test_factor.generate_factor    
    assert_equal 11.435594641924 , factor
  end  

  def test_imm_greater_than_comm
    #testing for an age immediate age being greater than commencement age
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 66.0
    test_factor.commencement_age = 65.0
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    factor = test_factor.generate_factor
    assert_equal "Error: Commencement age must be greater than or equal to immediate age" , factor
  end
  
  def test_temp_def_calc
    #testing for a temporary & deferred calculation
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 64.0
    test_factor.commencement_age = 65.0
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    test_factor.temporary_period = 1.0
    factor = test_factor.generate_factor    
    assert_equal "Error: Deferred Calculation with a Temporary Period" , factor
  end  
  
  def test_js_sp_young
    #testing for a J&S Factor where the spouse is younger than the primary
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 65.0
    test_factor.secondary_age = 47.6667
    test_factor.joint_survivor_type = 1.0
    test_factor.joint_survivor_percent = 0.67
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    factor = test_factor.generate_factor
    assert_equal 14.314945444020 , factor
  end  

  def test_js_sp_same
    #testing for a J&S Factor where the spouse is the same age as the primary
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 65.0
    test_factor.secondary_age = 65.0
    test_factor.joint_survivor_type = 1.0
    test_factor.joint_survivor_percent = 0.67
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    factor = test_factor.generate_factor
    assert_equal 12.692200767317 , factor
  end
 
  def test_js_sp_old
    #testing for a J&S Factor where the spouse is the same age as the primary
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 65.0
    test_factor.secondary_age = 67.167
    test_factor.joint_survivor_type = 1.0
    test_factor.joint_survivor_percent = 67.0
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    factor = test_factor.generate_factor    
    assert_equal 12.513757506115 , factor
  end 
  
  def test_js_true_sp_young
    #testing for a J&S Factor where the spouse is younger than the primary
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 65.0
    test_factor.secondary_age = 47.667
    test_factor.joint_survivor_type = 2.0
    test_factor.joint_survivor_percent = 67.0
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    factor = test_factor.generate_factor
    assert_equal 14.212643902413 , factor
  end  

  def test_js_true_sp_same
    #testing for a J&S Factor where the spouse is the same age as the primary
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 65.0
    test_factor.secondary_age = 65.0
    test_factor.joint_survivor_type = 2.0
    test_factor.joint_survivor_percent = 67.0
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    factor = test_factor.generate_factor
    assert_equal 12.073275362273 , factor
  end
 
  def test_js_true_sp_old
    #testing for a J&S Factor where the spouse is the same age as the primary
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 65.0
    test_factor.secondary_age = 67.167
    test_factor.joint_survivor_type = 2.0
    test_factor.joint_survivor_percent = 67.0
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    factor = test_factor.generate_factor
    assert_equal 11.777562337498 , factor
  end  
  
  def test_js_pop_sp_young
    #testing for a J&S Factor where the spouse is younger than the primary
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 65.0
    test_factor.secondary_age = 47.667
    test_factor.joint_survivor_type = 3.0
    test_factor.joint_survivor_percent = 67.0
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    factor = test_factor.generate_factor
    assert_equal 14.395175993773 , factor
  end  

  def test_js_pop_sp_same
    #testing for a J&S Factor where the spouse is the same age as the primary
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 65.0
    test_factor.secondary_age = 65.0
    test_factor.joint_survivor_type = 3.0
    test_factor.joint_survivor_percent = 67.0
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    factor = test_factor.generate_factor    
    assert_equal 12.938726797745 , factor
  end
 
  def test_js_pop_sp_old
    #testing for a J&S Factor where the spouse is the older than the primary
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 65.0
    test_factor.secondary_age = 67.167
    test_factor.joint_survivor_type = 3.0
    test_factor.joint_survivor_percent = 67.0
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    factor = test_factor.generate_factor    
    assert_equal 12.775066131083, factor
  end  
  
  def test_js_joint_sp_young
    #testing for a J&S Factor where the spouse is younger than the primary
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 65.0
    test_factor.secondary_age = 47.667
    test_factor.joint_survivor_type = 4.0
    test_factor.joint_survivor_percent = 67.0
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    factor = test_factor.generate_factor    
    assert_equal 11.125589970387 , factor
  end  

  def test_js_joint_sp_same
    #testing for a J&S Factor where the spouse is the same age as the primary
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 65.0
    test_factor.secondary_age = 65.0
    test_factor.joint_survivor_type = 4.0
    test_factor.joint_survivor_percent = 67.0
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    factor = test_factor.generate_factor    
    assert_equal 9.560063111486 , factor
  end
 
  def test_js_joint_sp_old
    #testing for a J&S Factor where the spouse is older than the primary
    test_factor = ActuarialFactor.new
    test_factor.immediate_age = 65.0
    test_factor.commencement_age = 65.0
    test_factor.secondary_age = 67.167
    test_factor.joint_survivor_type = 4.0
    test_factor.joint_survivor_percent = 67.0
    test_factor.interest_segment_a = 5.24
    test_factor.interest_segment_b = 5.69
    test_factor.interest_segment_c = 5.37
    test_factor.primary_mortality = MortalityTable::PPA2009
    factor = test_factor.generate_factor
    assert_equal 9.204700191569 , factor
  end  
  
  def default_test
      assert true
  end  
end
