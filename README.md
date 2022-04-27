# ParentalCountryOfBirth
This STATA syntax creates three variables from FAPLBINB (place of birth of father of new birth on a sample date) from the NBIR table.

It gives them value labels.

The three variables are:
- FAPLPRE92 for 1971-1991.
- FAPLFR92 for 1992-2006.
- FAPLFR07 for 2007 onwards.

Variables needed for this code are from the NBIR file:
- coreno
- faplbinb (Place of birth of father of new sample member)
- biyranb (birth year of new sample member)
	
### Warning
The code must be run on ALL the cases in the NBIR table. You can safely exclude cases afterwards. If you exclude cases beforehand, the process which assigns numerical values in place of string values to pre-1992 births (STATA command 'encode') may assign a different value to that which the value labels assume (because categories with small numbers of cases may have no cases after your exclusions).
