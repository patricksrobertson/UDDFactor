UDDFactor Release 2.0.0 (January 11th 2010)
============================================

**Homepage**: [http://github.com/jbplatter](http://github.com/jbcplatter)
**Author**: [Patrick Robertson](mailto:patricksrobertson@gmail.com)
**Copyright**: 2009-2010
**License**: [MIT License](file:LICENSE)


SYNOPSIS
--------

UDDFactor is a ruby plugin designed to calculate factors using the PPA mandated UDD factor calculation method.  

Currently, it only supports PPA2009-PPA2013 mortalities.  Feel free to add new ones!

INSTALLATION
------------

in the main directory of your rails app type:
	script/plugin add git://github.com/jbcplatter/UDDFactor.git


EXAMPLES
--------

This creates a 50% Joint and Survivor Annuity using the PPA2010 mortality table with three segment rates, and no certain/deferred periords and rounding to 6 decimal places.

	joint_survivor_factor = ActuarialFactor.new
	joint_survivor_factor.secondary_age = 61.0
	joint_survivor_factor.joint_survivor_type = 1.0
	joint_survivor_factor.joint_survivor_percent = 50.0
	joint_survivor_factor.primary_mortality = MortalityTable::PPA2010
	joint_survivor_factor.interest_segment_a = 5.44
	joint_survivor_factor.interest_segment_b = 5.24
	joint_survivor_factor.interest_segment_c = 5.69
	joint_survivor_factor.rounding = 6.0
	joint_survivor_factor.generate_factor

This creates a SLA factor with a 5 year certain period and 8 digit rounding.  This uses 5.44% for all three interest segments.
	sla_factor.primary_mortality = MortalityTable::PPA2013
	sla_factor.interest_segment_a = .0544
	sla_factor.interest_segment_b = nil
	sla_factor.interest_segment_c = nil
	sla_factor.certain_period = 5.0
	sla_factor.rounding = 8.0
	sla_factor.generate_factor
	
COPYRIGHT
---------

UDDFactor &copy; 2009 by [Patrick Robertson](mailto:patricksrobertson@gmail.com). Licensed under the MIT 
license. Please see the {file:LICENSE} for more information.
	


