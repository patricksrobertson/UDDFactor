# Include hook code here
require "actuarial_factor"
ActionController::Base.send :include, UDDFactor
ActionController::Base.send :include, AnnuityCertain
#ActionController::Base.send :include, ActuarialFactor

