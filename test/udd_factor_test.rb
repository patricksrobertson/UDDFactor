require File.dirname(__FILE__) + '/test_helper.rb' 
#require '/../lib/udd_factor'


class UDDFactorTest < Test::Unit::TestCase
  def test_nrd_sla
    #testing for an age 65 immediate factor
    factor = UDDFactor.generate_factor([65.0,65.0,0.0,0.0,0.0],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal 11.435594641924, factor
  end
  
  def test_nrd_sla_2010
    #testing for an age 65 immediate factor for 2010
    factor = UDDFactor.generate_factor([65.0,65.0,0.0,0.0,0.0],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,6.0,0.0],
                                       MortalityTable::PPA2010,
                                       nil)    
    assert_equal 11.458457 , factor
  end  
  
  def test_nrd_sla_2011
    #testing for an age 65 immediate factor for 2011
    factor = UDDFactor.generate_factor([65.0,65.0,0.0,0.0,0.0],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,6.0,0.0],
                                       MortalityTable::PPA2011,
                                       nil)     
    assert_equal 11.481172 , factor 
  end  
  
  def test_nrd_sla_2012
    #testing for an age 65 immediate factor for 2012
    factor = UDDFactor.generate_factor([65.0,65.0,0.0,0.0,0.0],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,6.0,0.0],
                                       MortalityTable::PPA2012,
                                       nil)
    assert_equal 11.503803 , factor
  end  
  
  def test_nrd_sla_2013
    #testing for an age 65 immediate factor for 2012
    factor = UDDFactor.generate_factor([65.0,65.0,0.0,0.0,0.0],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,6.0,0.0],
                                       MortalityTable::PPA2013,
                                       nil)
    assert_equal 11.52628 , factor
  end  
  
  def test_def_nrd_sla
    #testing for a deferred factor to 65.
    factor = UDDFactor.generate_factor([61.083,65.0,0.0,0.0,0.0],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal 8.995730102955 , factor
  end
  
  def test_imm_certain
    #testing for a immediate certain factor
    factor = UDDFactor.generate_factor([55.4166667,55.417,0.0,0.0,0.0],
                                       [5.24,5.69,5.37],
                                       [5.0,0.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal 13.938127140459 , factor
  end  
  
  def test_imm_temp
    #testing for a immediate temporary factor
    factor = UDDFactor.generate_factor([55.4166667,55.417,0.0,0.0,0.0],
                                       [5.24,5.69,5.37],
                                       [0.0,5.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)    
    assert_equal 4.390505351976 , factor
  end
  
  def test_imm_error
    #testing for an improper immediate age
    factor = UDDFactor.generate_factor(["waffle",55.417,0.0,0.0,0.0],
                                       [5.24,5.69,5.37],
                                       [0.0,5.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal "Immediate age cannot be converted into a number" , factor
  end  
  
  def test_imm_comm_error
    #testing for an improper immediate age + commencement age
    factor = UDDFactor.generate_factor(["waffle","waffle",0.0,0.0,0.0],
                                       [5.24,5.69,5.37],
                                       [0.0,5.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal "Immediate age cannot be converted into a number" +
                 "\n" + "Commencement age cannot be converted into a number " , factor
  end  
  
  def test_sp_error
    #testing for an improper spouse age
    factor = UDDFactor.generate_factor([65.0,55.417,"wrangle",0.0,0.0],
                                       [5.24,5.69,5.37],
                                       [0.0,5.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal "Spousal age cannot be converted into a number" , factor
  end  
  
  def test_js_type_error
    #testing for an improper js_type
    factor = UDDFactor.generate_factor([65.0,55.417,0.0,'c',0.0],
                                       [5.24,5.69,5.37],
                                       [0.0,5.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal "JS Type cannot be converted into a number" , factor
  end  
  
  def test_mort_type_error
    #testing for an improper mortality type
    factor = UDDFactor.generate_factor([65.0,55.417,0.0,0.0,0.0],
                                       [5.24,5.69,5.37],
                                       [0.0,5.0,12.0,0.0],
                                       "peanut",
                                       nil)
    assert_equal "Primary Mortality: Mortality Table must be an array"+ "\n" + 
                          "Secondary Mortality: Mortality Table must be an array " , factor
  end  
  
  def test_mort_array_settings
    #testing whether the array has at least two columns, elements are all floats
    test_array = [ [0.0, 0.0],['cap','trade']]
    factor = UDDFactor.generate_factor([65.0,55.417,0.0,0.0,0.0],
                                       [5.24,5.69,5.37],
                                       [0.0,5.0,12.0,0.0],
                                       test_array,
                                       nil)
    assert_equal "Primary Mortality: Invalid mortality table format: cannot convert all elements to numbers" +
                          "\n" +
                          "Secondary Mortality: Invalid mortality table format: cannot convert all elements to numbers " , factor
  end
  
  def test_mort_array_first
    #testing whether the array's first row is 0.0,0.0
    test_array = [ [0.0, 0.435],[2.0,1.0]]
    factor = UDDFactor.generate_factor([65.0,55.417,0.0,0.0,0.0],                                       
                                       [5.24,5.69,5.37],
                                       [0.0,5.0,12.0,0.0],
                                       test_array,
                                       nil)
    assert_equal "Primary Mortality: Invalid mortality table format: first row is not 0.0,0.0" + "\n" +
                         "Secondary Mortality: Invalid mortality table format: first row is not 0.0,0.0 " , factor
  end  
  
  def test_mort_array_last
    #testing whether the array's last row has a q(x) of 1.0
    test_array = [ [0.0, 0.000],[1.0, 0.035]]
    factor = UDDFactor.generate_factor([65.0,55.417,0.0,0.0,0.0],
                                       [5.24,5.69,5.37],
                                       [0.0,5.0,12.0,0.0],
                                       test_array,
                                       nil)
    assert_equal "Primary Mortality: Invalid mortality table format: last row does not have a q(x) of 1.0" + 
                         "\n" +
                         "Secondary Mortality: Invalid mortality table format: last row does not have a q(x) of 1.0 " , factor
  end  
  
  def test_js_pct_error
    #testing for an improper js_pct
    factor = UDDFactor.generate_factor([65.0,55.417,0.0,0.0,"waffles"],
                                       [5.24,5.69,5.37],
                                       [0.0,5.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal "JS percent cannot be converted into a number" , factor
  end  
  
  def test_int_a_error
    #testing for an improper interest segment A
    factor = UDDFactor.generate_factor([65.0,55.417,0.0,0.0,0.0],
                                       ["pancake",5.69,5.37],
                                       [0.0,5.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal "Interest segment A cannot be converted into a number" , factor
  end  
  
  def test_int_b_error
    #testing for an improper interest segment B
    factor = UDDFactor.generate_factor([65.0,55.417,0.0,0.0,0.0],
                                       [5.54,"ice cream",5.37],
                                       [0.0,5.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal "Interest segment B cannot be converted into a number", factor
  end  

  def test_int_c_error
    #testing for an improper interest segment c
    factor = UDDFactor.generate_factor([65.0,55.417,0.0,0.0,0.0],
                                       [5.54,0.0524,"claw"],
                                       [0.0,5.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal "Interest segment C cannot be converted into a number" , factor
  end  
  
  def test_certain_error
    #testing for an improper certain period
    factor = UDDFactor.generate_factor([65.0,55.417,0.0,0.0,0.0],
                                       [5.54,0.0524,5.37],
                                       ["peanut",5.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal "Certain period cannot be converted into a number" , factor
  end  

  def test_temp_error
    #testing for an improper temp period
    factor = UDDFactor.generate_factor([65.0,55.417,0.0,0.0,0.0],
                                       [5.54,0.0524,5.37],
                                       [0.0,"waff",12.0,0.0],
                                       MortalityTable::PPA2009,nil)
    assert_equal "Temporary period cannot be converted into a number", factor
  end
  
  def test_rounding_error
    #testing for an improper rounding
    factor = UDDFactor.generate_factor([65.0,55.417,0.0,0.0,0.0],
                                       [5.54,0.0524,5.37],
                                       [0.0,5.0,"growl",0.0],
                                       MortalityTable::PPA2009,
                                       nil)    
    assert_equal "Rounding cannot be converted into a number" , factor
  end  
  
  def test_default_imm
    #testing for defaulting immediate age
    factor = UDDFactor.generate_factor(["",65.0,0.0,0.0,0.0],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal 11.435594641924 , factor
  end  

  def test_imm_greater_than_comm
    #testing for an age immediate age being greater than commencement age
    factor = UDDFactor.generate_factor([66.0,65.0,0.0,0.0,0.0],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal "Error: Commencement age must be greater than or equal to immediate age" , factor
  end
  
  def test_temp_def_calc
    #testing for a temporary & deferred calculation
    factor = UDDFactor.generate_factor([64.0,65.0,0.0,0.0,0.0],
                                       [5.24,5.69,5.37],
                                       [0.0,1.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal "Error: Deferred Calculation with a Temporary Period" , factor
  end  
  
  def test_js_sp_young
    #testing for a J&S Factor where the spouse is younger than the primary
    factor = UDDFactor.generate_factor([65.0,65.0,47.667,1.0,0.67],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal 14.314945444020 , factor
  end  

  def test_js_sp_same
    #testing for a J&S Factor where the spouse is the same age as the primary
    factor = UDDFactor.generate_factor([65.0,65.0,65.0,1.0,67],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal 12.692200767317 , factor
  end
 
  def test_js_sp_old
    #testing for a J&S Factor where the spouse is the same age as the primary
    factor = UDDFactor.generate_factor([65.0,65.0,67.167,1.0,67],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal 12.513757506115 , factor
  end 
  
  def test_js_true_sp_young
    #testing for a J&S Factor where the spouse is younger than the primary
    factor = UDDFactor.generate_factor([65.0,65.0,47.667,2.0,0.67],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal 14.212643902413 , factor
  end  

  def test_js_true_sp_same
    #testing for a J&S Factor where the spouse is the same age as the primary
    factor = UDDFactor.generate_factor([65.0,65.0,65.0,2.0,67],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal 12.073275362273 , factor
  end
 
  def test_js_true_sp_old
    #testing for a J&S Factor where the spouse is the same age as the primary
    factor = UDDFactor.generate_factor([65.0,65.0,67.167,2.0,67],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal 11.777562337498 , factor
  end  
  
  def test_js_pop_sp_young
    #testing for a J&S Factor where the spouse is younger than the primary
    factor = UDDFactor.generate_factor([65.0,65.0,47.667,3.0,0.67],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal 14.395175993773 , factor
  end  

  def test_js_pop_sp_same
    #testing for a J&S Factor where the spouse is the same age as the primary
    factor = UDDFactor.generate_factor([65.0,65.0,65.0,3.0,67],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal 12.938726797745 , factor
  end
 
  def test_js_pop_sp_old
    #testing for a J&S Factor where the spouse is the same age as the primary
    factor = UDDFactor.generate_factor([65.0,65.0,67.167,3.0,67],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal 12.775066131083, factor
  end  
  
  def test_js_joint_sp_young
    #testing for a J&S Factor where the spouse is younger than the primary
    factor = UDDFactor.generate_factor([65.0,65.0,47.667,4.0,0.67],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal 11.125589970387 , factor
  end  

  def test_js_joint_sp_same
    #testing for a J&S Factor where the spouse is the same age as the primary
    factor = UDDFactor.generate_factor([65.0,65.0,65.0,4.0,67],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal 9.560063111486 , factor
  end
 
  def test_js_joint_sp_old
    #testing for a J&S Factor where the spouse is the same age as the primary
    factor = UDDFactor.generate_factor([65.0,65.0,67.167,4.0,67],
                                       [5.24,5.69,5.37],
                                       [0.0,0.0,12.0,0.0],
                                       MortalityTable::PPA2009,
                                       nil)
    assert_equal 9.204700191569 , factor
  end  
  
  def default_test
      assert true
  end  
end
