class ActuarialFactor
  attr_accessor :immediate_age,:commencement_age,:secondary_age,
                :joint_survivor_type,:joint_survivor_percent,
                :primary_mortality,:secondary_mortality,
                :interest_segment_a,:interest_segment_b,:interest_segment_c,
                :certain_period,:temporary_period,:rounding,
                :output_type,:errors
  
  include UDDFactor
  include GenFactor
  include MortalityTable
  
  def initialize
    @immediate_age = 0.0
    @commencement_age = 65.0
    @secondary_age = 0.0
    @joint_survivor_type = 0.0
    @joint_survivor_percent = 0.0
    @primary_mortality = MortalityTable::PPA2009
    @secondary_mortality = nil
    @interest_segment_a = 5.0
    @interest_segment_b = 0.0
    @interest_segment_c = 0.0
    @certain_period = 0.0
    @temporary_period = 0.0
    @rounding = 12.0
    @output_type = 0.0
    @errors = []
  end
end