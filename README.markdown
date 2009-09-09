UDDFactor Release 1.0.0 (September 9th 2009)
============================================

**Homepage**: [http://github.com/jbplatter](http://github.com/jbcplatter)
**Author**: Patrick Robertson
**Copyright**: 2009
**License**: MIT License


SYNOPSIS
--------

UDDFactor is a ruby plugin designed to calculate factors using the PPA mandated UDD factor calculation method.  

Currently, it only supports PPA2009-PPA2013 mortalities.  Feel free to add new ones!


EXAMPLES
--------

This creates a 50% Joint and Survivor Annuity using the PPA2010 mortality table with three segment rates, and no certain/deferred periords and rounding to 6 decimal places.

	UDDFactor::generate_factor(65.0,65.0,61.0,1.0,50,MortalityTable::PPA2010,5.44,5.24,5.69,0,0,6.0)

This creates a SLA factor with a 5 year certain period and 8 digit rounding.  This uses 5.44% for all three interest segments.
	
	UDDFactor::generate_factor(,65.0,,,MortalityTable::PPA2013,.0544,,,5,,8.0)
	
COPYRIGHT
---------

UDDFactor &copy; 2009 by [Patrick Robertson](mailto:patricksrobertson@gmail.com). Licensed under the MIT 
license. Please see the {file:LICENSE} for more information.
	


