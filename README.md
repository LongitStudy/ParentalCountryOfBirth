# MotherCountryOfBirth
This STATA syntax creates three variables from the variable moplbinb (Place of birth of mother of new birth on sample date) from the NBIR table. It gives them value labels.

The three variables are:
- moplpre92 for births from 1971 to 1991.
- moplfr92 for births from 1992 to 2006.
- moplfr07 for births from 2007 onwards.

Variables needed for this code are from the NBIR file:
- coreno
- moplbinb (Place of birth of mother of new sample member)
- biyranb (birth year of new sample member)

### Warning
The code must be run on ALL the cases in the NBIR table. You can safely exclude cases afterwards. If you exclude cases beforehand, the process which assigns numerical values in place of string values to pre-1992 births (STATA command 'encode') may assign a different value to that which the value labels assume (because categories with small numbers of cases may have no cases after your exclusions).
