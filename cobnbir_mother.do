/*cobnbir

This code creates three variables from MOPLBINB (Place of birth of mother of 
	new birth on sample date (from NBIR table)).
	It gives them value labels.
	The three variables are:
		-MOPLPRE92 FOR 1971-1991
		-MOPLFR92 for 1992-2006
		-MOPLFR07 for 2007 onwards
Variables needed for this code (all from NBIR):
	coreno
	moplbinb (Place of birth of mother of new sample member)
	biyranb (birth year of new sample member)
	
************************************WARNING*************************************
*The code must be run on ALL the cases in the NBIR table.
	You can safely exclude cases afterwards.
	If you exclude cases beforehand, the process which assigns numerical values 
	in place of string values to pre-1992 births (STATA command 'encode') may 
	assign a different value to that which the value labels assume (because 
	categories with small numbers of cases may have no cases after your exclusions).
*********************************END OF WARNING*********************************

1) Make sure that you change your working directory to your project area
cd "P:\......"

2) Open the dataset that you want to add the derived variable to. Make sure that it has all the variables that are in the variables list above)
********************************************************************************/

tab moplbinb

*count the length of the value minus spaces
gen str shrtmopl=moplbinb
replace shrtmopl=substr(moplbinb,1,4) if substr(moplbinb,5,1)==" "
replace shrtmopl=substr(moplbinb,1,3) if substr(moplbinb,4,1)==" "
gen len=length(shrtmopl)
drop shrtmopl
tab len

*create an initial numeric version of moplbinb (won't work for all coding schemes)
gen nummopl=.
replace nummopl=real(substr(moplbinb,1,3)) if substr(moplbinb,5,1)==" "
replace nummopl=real(substr(moplbinb,1,3)) if substr(moplbinb,4,1)==" "
replace nummopl=real(substr(moplbinb,1,5)) if substr(moplbinb,5,1)~=" "

*create a marker variable for those starting '99'
gen code99=0
replace code99=1 if substr(moplbinb,1,2)=="99"

*identify the fifth digit if any (often a space)
gen str last="none"
replace last=substr(moplbinb,5,1)
tab last

*create an empty string variable with 4 places
gen str CX="    "

*create a variable which will distinguish between coding schemes
gen codschem=0

/*if it ends with a 9 and has 5 characters and the first 3 are 101 or more and 
the first four are not more than 5925 (England)*/
replace CX="  3C" if last=="9" & len==5 & nummopl>=01010 & nummopl<=59259
replace codschem=1 if last=="9" & len==5 & nummopl>=01010 & nummopl<=59259

/*else if it ends with a 9 and has 5 characters and the first 4 are 6105 to 6820
(Wales)*/
replace CX="  3G" if last=="9" & len==5 & nummopl>61049 & nummopl<68210 & CX=="    "
replace codschem=1 if last=="9" & len==5 & nummopl>61049 & nummopl<68210 & codschem==0

*else if it begins with 99 and then has a 0 or 1 (Scotland)
replace CX="  1W" if code99==1 & (substr(moplbinb,3,1)=="0" | substr(moplbinb,3,1)=="1") & CX=="    "
replace codschem=1 if code99==1 & (substr(moplbinb,3,1)=="0" | substr(moplbinb,3,1)=="1") & codschem==0

*else if it begins with 99 and then has a 2 (Northern Ireland)
replace CX="  2W" if code99==1 & substr(moplbinb,3,1)=="2" & CX=="    "
replace codschem=1 if code99==1 & substr(moplbinb,3,1)=="2" & codschem==0

*else if it's pre-1992 and begins with 99 ie foreign (knocks off the 99)
replace CX="  "+substr(moplbinb,3,2) if biyranb<1992 & code99==1 & CX=="    "
replace codschem=1 if biyranb<1992 & code99==1 & codschem==0

*else if it's pre-2007 and codschem has been set to 0 (which was the default).
replace CX=moplbinb if biyranb<2007 & codschem==0 & CX=="    "
replace codschem=2 if biyranb<2007 & codschem==0

*else if it's 2007 or later and codschem has been set to 0.
replace CX=moplbinb if biyranb>2006 & codschem==0 & CX=="    "
replace codschem=3 if biyranb>2006 & codschem==0

gen str WWW="na"
replace WWW=CX if codschem==1
gen str YYY="na"
replace YYY=CX if codschem==2
gen str ZZZ="na"
replace ZZZ=CX if codschem==3

*can't create value labels for string vars in STATA so need to create numeric vars

*************************

gen str scheme1="na"
replace scheme1=CX if codschem==1
encode scheme1, gen (moplpre92)
label define cob8  1 "Scotland" 2 "Northern Ireland" 3 "Irish Republic" 4 "IOM&Channel Isles" 5 "England/UK" ///
  6 "Ireland, part not stated" 7 "Guernsey" 8 "Jersey" 9 "Wales" 10 "Channel Islands other" 11 "Not Stated" ///
  12 "Norway/Sweden" 13 "Finland" 14 "Iceland" 15 "Belgium/Luxembourg" ///
  16 "Netherlands" 17 "Denmark/Greenland" 18 "France/Monaco" 19 "Spain/Canary/Balearic Isles" ///
  20 "Portugal/Azores/Madeira" 21 "Turkey" 22 "Italy/San Marino/Vatican City" ///
  23 "Austria" 24 "German DR" 25 "Switzerland/Liechtenstein" 26 "FR Germany/Germany part n/s" 27 "Greece" ///
  28 "Czechoslovakia" 29 "Yugoslavia" 30 "Albania/Bulgaria" 31 "Other Europe" 32 "Hungary"  ///
  33 "Poland" 34 "Romania" 35 "Gibraltar" 36 "Malta & Gozo" 37 "The Gambia" 38 "Ghana" 39 "Sierra Leone" ///
  40 "Nigeria" 41 "Botswana/Lesotho/Swaziland" 42 "Zimbabwe" 43 "Kenya" 44 "Malawi" 45 "Tanzania" 46 "Uganda" ///
  47 "Zambia" 48 "Seychelles/Mauritius/Other New C" 49 "Other CW Africa" 50 "Cyprus" 51 "Banglandesh" ///
  52 "India" 53 "Sri Lanka" 54 "Malasia/Singapore" 55 "Hong Kong" 56 "Australia" 57 "New Zealand" ///
  58 "Other CW Pacific" 59 "Canada" 60 "Belize" 61 "Barbados" 62 "Jamaica" 63 "Trinida & Tobago" ///
  64 "West Indian Assoc. States/Other Caribbean CW" 65 "West Indies" 66 "Guyana" ///
  67 "CW Sth. Atlantic islands" 68 "USA" 69 "Central America (Mainland)" 70 "Caribbean non-CW" ///
  71 "Brazil" 72 "Other Tropical Sth. America" 73 "Argentina" 74 "Chile" 75 "Bolivia/Paraguay/Uruguay" ///
  76 "Other Sth. America"  77 "Non-CW West Africa Muslim" 78 "Non-CW West Africa other" ///
  79 "Other Africa (foreign)" 80 "Libya" ///
  81 "Angola" 82 "Republic of South Africa" 83 "Mozambique" 84 "Morocco" 85 "Algeria" 86 "Tunisia" ///
  87 "Egypt" 88 "Sudan" 89 "Ethiopia/Somalia" 90 "Malagasy Rep/Islands in Indian Ocean" 91 "Libya 2" ///
  92 "Other non-CW Africa" 93 "Israel" 94 "Syria" 95 "Palestine" 96 "Iraq" ///
  97 "Iran" 98 "Other Middle East" 99 "Burma/other Asia (foreign)" 100 "Philippines/Vietnam" ///
  101 "China/Taiwan" 102 "Japan" 103 "USSR" 104 "Non-CW islands in Pacific" 105 "Pakistan"  
label values moplpre92 cob8
replace moplpre92=. if moplpre92==107
lab var moplpre92 "Mother's place of birth, for LSMs born 1971-1991"
************************


gen tempcob = moplbinb if codschem==2

*replacing the letters (which are small associated territories etcc) with numbers at beginning
replace tempcob = "1"+substr(tempcob,1,3) if substr(tempcob,4,1) == "A" 
replace tempcob = "2"+substr(tempcob,1,3) if substr(tempcob,4,1) == "B" 
replace tempcob = "3"+substr(tempcob,1,3) if substr(tempcob,4,1) == "C" 
replace tempcob = "4"+substr(tempcob,1,3) if substr(tempcob,4,1) == "D"
replace tempcob = "5"+substr(tempcob,1,3) if substr(tempcob,4,1) == "E"
replace tempcob = "6"+substr(tempcob,1,3) if substr(tempcob,4,1) == "F" 
replace tempcob = "7"+substr(tempcob,1,3) if substr(tempcob,4,1) == "G" 
replace tempcob = "8"+substr(tempcob,1,3) if substr(tempcob,4,1) == "H" 
replace tempcob = "9"+substr(tempcob,1,3) if substr(tempcob,4,1) == "J" 

gen int moplfr92 = real(tempcob)
replace moplfr92=719 if moplfr92==232 | moplfr92==299
drop tempcob

label define cob01 1 "Afghanistan" ///  
      2 "Albania"  ///
      3 "Alderney"  ///
      4 "Algeria"  ///
      5 "Andorra"  ///
      6 "Angola"  ///
      1006 "Cabinda"  ///
      7 "Anguilla"  ///
      8 "Antigua and Barbuda" /// 
      1008 "Antigua"  ///
      2008 "Barbuda"  ///
      9 "Argentina"  ///
      1009 "Argentina Antarctic Territory" ///  
	10 "Armenia" ///
      11 "Australia" ///  
      1011 "Australian Antarctic Territory"  ///
      2011 "Christmas Island (Australia) " ///
      3011 "Cocos (Keeling) Isalands"  ///
      4011 "Coral Sea Islands Territory"  ///
      5011 "Heard and McDonald Islands"  ///
      6011 "Norfolk Island"  ///
      12 "Austria" ///
      13 "Azerbaijan"  ///
      14 "Bahamas" ///
      15 "Bahrain" ///
      16 "Bangladesh"  ///
      17 "Barbados" ///
      18 "Belarus" ///
      19 "Belgium" ///
      20 "Belize" ///
      21 "Benin" ///
      22 "Bermuda" ///
      23 "Bhutan" ///
      24 "Bolivia" ///
      25 "Bosnia and Herzegovina" ///
      26 "Botswana" ///
      27 "Brazil" ///
      28 "British Antarctic Territory"  ///
      29 "British Indian Ocean Territory"  ///
      30 "British Virgin Islands"  ///
      31 "Brunei"  ///
      32 "Bulgaria"  ///
      33 "Burkina Faso" /// 
      34 "Myanmar"  ///
      35 "Burundi"  ///
      36 "Cambodia"  ///
      37 "Cameroon"  ///
      38 "Canada"  ///
      39 "Cape Verde"  ///
      40 "Caroline Islands"  ///
      41 "Cayman Islands" ///  
      42 "Central African Republic" ///  
      43 "Chad" ///
      44 "Channel Islands" ///
      45 "Chile" ///
      1045 "Chilean Antarctic" ///
      46 "China" ///
      1046 "Tibet" ///
      2046 "Hong Kong" /// 
      47 "Colombia" ///
      48 "Commonwealth of (Russian) Independent States States" ///
      49 "Comoros" ///
      50 "Congo" ///
      51 "Cook Islands" ///
      52 "Costa Rica" ///  
      53 "Croatia" ///  
      54 "Cuba" ///
      55 "Cyprus" ///
      56 "Czech Republic" ///
      57 "Denmark" ///
      58 "Djibouti" ///
      59 "Dominica" ///
      60 "Dominican Republic" /// 
      61 "Ecuado" ///
      62 "Egypt" ///
      63 "El Salvador" ///
      64 "England" ///
      65 "Equatorial Guinea" ///
      66 "Estonia" ///
      67 "Ethiopia" ///
      68 "Falkland Islands" ///
      1068 "East Falkland" ///
      2068 "West Falkland" ///  
      69 "Fiji" ///
      70 "Finland" ///  
      71 "France" ///
      1071 "French Guiana" ///
      2071 "Polynesia" ///
      3071 "French Polynesia" ///
      4071 "Gaudeloupe" ///
      5071 "Martinique" ///
      6071 "New Caledonia" /// 
      7071 "St Pierre et Miquelon" ///
      8071 "Wallis and Futuna Islands" ///  
      72 "Gabon" ///
      73 "Gambia" ///
      74 "Georgia Republic" ///
      1074 "Loyalty Islands" ///
      75 "Germany" ///
	2075 "West Germany" ///
      76 "Ghana" ///
      77 "Gibraltar" /// 
      78 "Great Britain" /// 
      79 "Greece" ///
      1079 "Crete" ///
      2079 "Dodecanese Islands" ///
      3079 "Ionian Islands" ///
      80 "Greenland" ///
      81 "Grenada" ///
      82 "Guatemala" ///
      83 "Guernsey" ///
      1083 "Herm" ///
      2083 "Jethou Island" ///
      3083 "Lihou" ///
      84 "Guinea" ///
      85 "Guinea-Bissau" ///
      86 "Guyana" ///
      87 "Haiti" ///
      88 "Herzegovina " ///
      89 "Honduras" ///
	90 "Hong Kong" ///
      91 "Hungary" ///
      92 "Iceland" ///
      93 "India" ///  
      1093 "Kashmir" ///
      94 "Indonesia" ///  
      2094 "Java"  ///
      95 "Iran" ///
      96 "Iraq" ///
      97 "Republic of Ireland" ///  
      98 "Israel" ///  
      1098 "Occupied Territories (Gaza & West Bank)" ///  
      99 "Italy" ///  
      1099 "Vatican City State" ///  
      100 "Ivory Coast" ///  
      101 "Jamaica" ///  
      102 "Japan" ///  
      103 "Jersey" ///  
      104 "Jordan" ///  
      105 "Kazakhstan" ///  
      106 "Kenya" ///  
      107 "Kiribati" ///  
      108 "North Korea" ///  
      109 "South Korea" ///  
      110 "Kuwait" ///  
      111 "Kyrgyzstan" ///  
      112 "Laos" ///  
      113 "Latvia" ///  
      114 "Lebanon" ///  
      115 "Lesotho" ///  
      116 "Liberia" ///  
      117 "Libya" ///  
      118 "Liechtenstein" ///  
      119 "Lithuania" ///  
      120 "Luxembourg" ///  
      121 "Macedonia" ///  
      122 "Madagascar" ///  
      123 "Malawi" ///  
      124 "Malaysia" ///  
      125 "Maldives" ///  
      126 "Mali" ///  
      127 "Malta" ///  
      128 "Isle of Man" ///  
      129 "Marshall Islands" ///  
      130 "Mauritania" ///  
      131 "Mauritius" ///  
      132 "Mexico" ///  
      133 "Federated States of Micronesia" ///  
      134 "Moldova" ///  
      135 "Monaco" ///  
      136 "Mongolia" ///  
      137 "Montserrat" ///  
      138 "Montenegro" ///  
      139 "Morocco" ///  
      140 "Mozambique" ///  
      141 "Namibia" ///  
      142 "Nauru " /// 
      143 "Nepal" ///  
      144 "The Netherlands" ///  
      145 "Netherland Antilles" ///  
      2145 "Bonaire" ///  
      3145 "Curacao" ///  
      147 "New Zealand" ///  
      1147 "Ross Dependency" ///  
      1147 "Tokelau Islands" ///  
      148 "Nicaragua" ///  
      149 "Niger" ///  
      150 "Nigeria" ///  
      151 "Niue" ///  
      152 "Northern Ireland" ///  
      153 "Norway" ///  
      1153 "Norwegian Antarctic Territory" ///  
      2153 "Peter Island" ///  
      3153 "Queen Maud Land" ///  
      154 "Oman" ///  
      155 "Pakistan" ///  
      156 "Palestine" ///  
      157 "Panama" ///  
      1157 "Panama Canal Zone" ///  
      158 "Papua New Guinea" ///  
      159 "Paraguay" ///  
      160 "Peru" ///  
      161 "Philippines" ///  
      162 "Pitcairn Islands Group" ///  
      163 "Poland" ///  
      164 "Portugal" ///  
      1164 "Azores" ///  
      2164 "Macao" ///  
      165 "Puerto Rico" ///  
      166 "Qatar" ///  
      167 "Reunion" ///  
      168 "Romania" ///  
      169 "Russia" ///  
      170 "Rwanda" ///  
      171 "St Kitts - Nevis" ///  
      172 "St Helena" ///  
      1172 "Ascension Island" ///  
      2172 "Gough Island" ///  
      3172 "Inaccessible Island" ///  
      4172 "Middle Island" ///  
      5172 "Nightingale Island" ///  
      6172 "Stoltenhoff Island" ///  
      7172 "Tristan da Cunha" ///  
      173 "St Lucia" ///  
      174 "St Vincent and the Grenadines" ///  
      175 "San Marino" ///  
      176 "Sao Tome and Principe" ///  
      177 "Sark" ///  
      178 "Saudi Arabia" ///  
      179 "Scotland" ///  
      180 "Senegal" ///  
      181 "Serbia & Montenegro" ///  
      1181 "Kosovo" ///  
      182 "Seychelles" ///  
      183 "Sierra Leone" ///  
      184 "Singapore" ///  
      185 "Slovakia" ///  
      186 "Slovenia" ///  
      187 "Solomon Islands" ///  
      188 "Somalia" ///  
      189 "South Africa" ///  
      1189 "Bantu Homelands" ///  
      2189 "Bophuthatswana" ///  
      3189 "Transkei" ///  
      5189 "Walvis Bay" ///  
      190 "Spain" ///  
      1190 "Canary Islands" ///  
      2190 "Ceuta" ///  
      3190 "Ibiza" ///  
      4190 "Melilla" ///  
      191 "Sri Lanka" ///  
      192 "Sudan" ///  
      193 "Surinam" ///  
      194 "Swaziland" ///  
      195 "Sweden" ///  
      196 "Switzerland" ///  
      197 "Syria" ///  
      198 "Taiwan" ///  
      199 "Tajikistan" ///  
      200 "Tanzania" ///  
      201 "Thailand" ///  
      202 "Togo" ///  
      203 "Tonga" ///  
      204 "Trinidad and Tobago" ///  
      205 "Tunisia" ///  
      206 "Turkey" ///  
      207 "Turkmenistan" ///  
      208 "Turks and Caicos Islands" ///  
      209 "Tuvalu" ///  
      210 "Uganda" ///
	211 "Ukraine" ///  
      212 "United Arab Emirates" ///  
      1212 "Abu Dhabi" ///  
      2212 "Ajman" ///  
      3212 "Dubai" ///  
      4212 "Fujairah" ///  
      5212 "Ras al Khaimah" ///  
      6212 "Sharjah" ///  
      7212 "Umm al Qaiwain" ///  
      213 "United Kingdom" ///  
      214 "U.S.A" ///  
      1214 "East Samoa (American)" ///  
      2214 "Guam" /// 
      3214 "Johnston Atoll/Island" ///  
      4214 "Kingman Reef" ///  
      5214 "US Pacific Islands" ///  
      6214 "Palau" ///  
      7214 "Palmyra Islands" ///  
      8214 "US Virgin Islands" ///  
      9214 "Wake Island" ///  
      215 "Uruguay" ///  
      216 "Uzbekistan" ///  
      217 "Vanuatu" ///  
      218 "Venezuela" ///  
      219 "Vietnam" ///  
      220 "Wales" ///  
      221 "Western Samoa" ///  
      222 "Yemen" ///  
      1222 "Aden" ///  
      223 "Yugoslavia" ///  
      224 "Democratic Republic of Congo" ///  
      225 "Zambia" ///  
      226 "Zimbabwe" ///  
      227 "Czechoslovakia" ///  
      228 "Union of Soviet Socialist States" ///  
      229 "Eritrea" ///  
      230 "Armenia" ///  
      231 "Ukraine" ///
	705 "Foreign Caribbean" ///
	707 "Central America" ///
	719 "Elsewhere or not stated" ///
	721 "Other Commonwealth or Pacific islands" ///
	722 "Other Caribbean CW" ///
	741 "Middle East other" ///
      900 "At Sea" ///  
	901 "Inadeq. desc" ///
      903 "In the Air" ///  
	906 "Not stated" ///
      920 "Africa - East" ///  
      921 "Africa - North" ///  
      922 "Africa - West" ///  
	923 "America not otherwise stated" ///
      924 "Asia" ///  
	926 "African CW not otherwise stated" ///
      927 "Europe" ///  
	928 "Africa foreign not otherwise stated" ///
      930 "Ireland (not otherwise stated)" ///  
      931 "Middle East" ///  
      934 "South America" ///  
      937 "West Indies" ///  
      939 "Africa (not otherwise stated)" ///  
      727 "England & Wales"

label values moplfr92 cob01
lab var moplfr92 "Mother's place of birth, for LSMs born 1992-2006"

**************

*the codes from 2007 on are three numbers, then two spaces (making a length of 5 in all)
gen moplfr07=nummopl if biyranb>2006
lab def zzz  4 "Afghanistan "
lab def zzz  8 "Albania ", add
lab def zzz  10 "Antarctica ", add
lab def zzz  12 "Algeria ", add
lab def zzz  16 "American Samoa ", add
lab def zzz  20 "Andorra ", add
lab def zzz  24 "Angola ", add
lab def zzz  28 "Antigua and Barbuda ", add
lab def zzz  31 "Azerbaijan ", add
lab def zzz  32 "Argentina ", add
lab def zzz  36 "Australia ", add
lab def zzz  40 "Austria ", add
lab def zzz  44 "Bahamas ", add
lab def zzz  48 "Bahrain ", add
lab def zzz  50 "Bangladesh ", add
lab def zzz  51 "Armenia ", add
lab def zzz  52 "Barbados ", add
lab def zzz  56 "Belgium ", add
lab def zzz  60 "Bermuda ", add
lab def zzz  64 "Bhutan ", add
lab def zzz  68 "Bolivia ", add
lab def zzz  70 "Bosnia and Herzegovina ", add
lab def zzz  72 "Botswana ", add
lab def zzz  74 "Bouvet Island  ", add
lab def zzz  76 "Brazil ", add
lab def zzz  84 "Belize ", add
lab def zzz  86 "British Indian Ocean Territory  ", add
lab def zzz  90 "Solomon Islands ", add
lab def zzz  92 "British Virgin Islands ", add
lab def zzz  96 "Brunei ", add
lab def zzz  100 "Bulgaria ", add
lab def zzz  104 "Burma ", add
lab def zzz  108 "Burundi ", add
lab def zzz  112 "Belarus ", add
lab def zzz  116 "Cambodia ", add
lab def zzz  120 "Cameroon ", add
lab def zzz  124 "Canada ", add
lab def zzz  132 "Cape Verde ", add
lab def zzz  136 "Cayman Islands ", add
lab def zzz  140 "Central African Republic ", add
lab def zzz  144 "Sri Lanka ", add
lab def zzz  148 "Chad ", add
lab def zzz  152 "Chile ", add
lab def zzz  156 "China ", add
lab def zzz  158 "Taiwan ", add
lab def zzz  162 "Christmas Island  ", add
lab def zzz  166 "Cocos (Keeling) Islands  ", add
lab def zzz  170 "Colombia ", add
lab def zzz  174 "Comoros ", add
lab def zzz  175 "Mayotte ", add
lab def zzz  178 "Congo ", add
lab def zzz  180 "Congo (Democratic Republic) ", add
lab def zzz  184 "Cook Islands ", add
lab def zzz  188 "Costa Rica ", add
lab def zzz  191 "Croatia ", add
lab def zzz  192 "Cuba ", add
lab def zzz  203 "Czech Republic ", add
lab def zzz  204 "Benin ", add
lab def zzz  208 "Denmark ", add
lab def zzz  212 "Dominica ", add
lab def zzz  214 "Dominican Republic ", add
lab def zzz  218 "Ecuador ", add
lab def zzz  222 "El Salvador ", add
lab def zzz  226 "Equatorial Guinea ", add
lab def zzz  231 "Ethiopia ", add
lab def zzz  232 "Eritrea ", add
lab def zzz  233 "Estonia ", add
lab def zzz  234 "Faroe Islands ", add
lab def zzz  238 "Falkland Islands ", add
lab def zzz  239 "South Georgia and the South Sandwich Islands  ", add
lab def zzz  242 "Fiji ", add
lab def zzz  246 "Finland ", add
lab def zzz  248 "Aland Islands ", add
lab def zzz  250 "France ", add
lab def zzz  254 "French Guiana ", add
lab def zzz  258 "French Polynesia ", add
lab def zzz  260 "French Southern Territories  ", add
lab def zzz  262 "Djibouti ", add
lab def zzz  266 "Gabon ", add
lab def zzz  268 "Georgia ", add
lab def zzz  270 "Gambia ", add
lab def zzz  275 "Occupied Palestinian Territories ", add
lab def zzz  276 "Germany ", add
lab def zzz  288 "Ghana ", add
lab def zzz  292 "Gibraltar ", add
lab def zzz  296 "Kiribati ", add
lab def zzz  300 "Greece ", add
lab def zzz  304 "Greenland ", add
lab def zzz  308 "Grenada ", add
lab def zzz  312 "Guadeloupe ", add
lab def zzz  316 "Guam ", add
lab def zzz  320 "Guatemala ", add
lab def zzz  324 "Guinea ", add
lab def zzz  328 "Guyana ", add
lab def zzz  332 "Haiti ", add
lab def zzz  334 "Heard Island and McDonald Islands  ", add
lab def zzz  336 "Vatican City ", add
lab def zzz  340 "Honduras ", add
lab def zzz  344 "Hong Kong (Special Administrative Region of China) ", add
lab def zzz  348 "Hungary ", add
lab def zzz  352 "Iceland ", add
lab def zzz  356 "India ", add
lab def zzz  360 "Indonesia ", add
lab def zzz  364 "Iran ", add
lab def zzz  368 "Iraq ", add
lab def zzz  372 "Ireland ", add
lab def zzz  376 "Israel ", add
lab def zzz  380 "Italy ", add
lab def zzz  384 "Ivory Coast ", add
lab def zzz  388 "Jamaica ", add
lab def zzz  392 "Japan ", add
lab def zzz  398 "Kazakhstan ", add
lab def zzz  400 "Jordan ", add
lab def zzz  404 "Kenya ", add
lab def zzz  408 "Korea (North) ", add
lab def zzz  410 "Korea (South) ", add
lab def zzz  414 "Kuwait ", add
lab def zzz  417 "Kyrgyzstan ", add
lab def zzz  418 "Laos ", add
lab def zzz  422 "Lebanon ", add
lab def zzz  426 "Lesotho ", add
lab def zzz  428 "Latvia ", add
lab def zzz  430 "Liberia ", add
lab def zzz  434 "Libya ", add
lab def zzz  438 "Liechtenstein ", add
lab def zzz  440 "Lithuania ", add
lab def zzz  442 "Luxembourg ", add
lab def zzz  446 "Macao (Special Administrative Region of China) ", add
lab def zzz  450 "Madagascar ", add
lab def zzz  454 "Malawi ", add
lab def zzz  458 "Malaysia ", add
lab def zzz  462 "Maldives ", add
lab def zzz  466 "Mali ", add
lab def zzz  470 "Malta ", add
lab def zzz  474 "Martinique ", add
lab def zzz  478 "Mauritania ", add
lab def zzz  480 "Mauritius ", add
lab def zzz  484 "Mexico ", add
lab def zzz  492 "Monaco ", add
lab def zzz  496 "Mongolia ", add
lab def zzz  498 "Moldova ", add
lab def zzz  499 "Montenegro ", add
lab def zzz  500 "Montserrat ", add
lab def zzz  504 "Morocco ", add
lab def zzz  508 "Mozambique ", add
lab def zzz  512 "Oman ", add
lab def zzz  516 "Namibia ", add
lab def zzz  520 "Nauru ", add
lab def zzz  524 "Nepal ", add
lab def zzz  528 "Netherlands ", add
lab def zzz  530 "Netherlands Antilles ", add
lab def zzz  533 "Aruba ", add
lab def zzz  540 "New Caledonia ", add
lab def zzz  548 "Vanuatu ", add
lab def zzz  554 "New Zealand ", add
lab def zzz  558 "Nicaragua ", add
lab def zzz  562 "Niger ", add
lab def zzz  566 "Nigeria ", add
lab def zzz  570 "Niue ", add
lab def zzz  574 "Norfolk Island ", add
lab def zzz  578 "Norway ", add
lab def zzz  580 "Northern Mariana Islands ", add
lab def zzz  581 "United States Minor Outlying Islands  ", add
lab def zzz  583 "Micronesia ", add
lab def zzz  584 "Marshall Islands ", add
lab def zzz  585 "Palau ", add
lab def zzz  586 "Pakistan ", add
lab def zzz  591 "Panama ", add
lab def zzz  598 "Papua New Guinea ", add
lab def zzz  600 "Paraguay ", add
lab def zzz  604 "Peru ", add
lab def zzz  608 "Philippines ", add
lab def zzz  612 "Pitcairn Henderson Ducie and Oeno Islands ", add
lab def zzz  616 "Poland ", add
lab def zzz  620 "Portugal ", add
lab def zzz  624 "Guinea-Bissau ", add
lab def zzz  626 "East Timor ", add
lab def zzz  630 "Puerto Rico ", add
lab def zzz  634 "Qatar ", add
lab def zzz  638 "RÚunion ", add
lab def zzz  642 "Romania ", add
lab def zzz  643 "Russia ", add
lab def zzz  646 "Rwanda ", add
lab def zzz  654 "St Helena ", add
lab def zzz  659 "St Kitts and Nevis ", add
lab def zzz  660 "Anguilla ", add
lab def zzz  662 "St Lucia ", add
lab def zzz  666 "St Pierre and Miquelon ", add
lab def zzz  670 "St Vincent and the Grenadines ", add
lab def zzz  674 "San Marino ", add
lab def zzz  678 "Sao Tome and Principe ", add
lab def zzz  682 "Saudi Arabia ", add
lab def zzz  686 "Senegal ", add
lab def zzz  688 "Serbia ", add
lab def zzz  690 "Seychelles ", add
lab def zzz  694 "Sierra Leone ", add
lab def zzz  702 "Singapore ", add
lab def zzz  703 "Slovakia ", add
lab def zzz  704 "Vietnam ", add
lab def zzz  705 "Slovenia ", add
lab def zzz  706 "Somalia ", add
lab def zzz  710 "South Africa ", add
lab def zzz  716 "Zimbabwe ", add
lab def zzz  732 "Western Sahara ", add
lab def zzz  736 "Sudan ", add
lab def zzz  740 "Surinam ", add
lab def zzz  744 "Svalbard and Jan Mayen ", add
lab def zzz  748 "Swaziland ", add
lab def zzz  752 "Sweden ", add
lab def zzz  756 "Switzerland ", add
lab def zzz  760 "Syria ", add
lab def zzz  762 "Tajikistan ", add
lab def zzz  764 "Thailand ", add
lab def zzz  768 "Togo ", add
lab def zzz  772 "Tokelau ", add
lab def zzz  776 "Tonga ", add
lab def zzz  780 "Trinidad and Tobago ", add
lab def zzz  784 "United Arab Emirates ", add
lab def zzz  788 "Tunisia ", add
lab def zzz  792 "Turkey ", add
lab def zzz  795 "Turkmenistan ", add
lab def zzz  796 "Turks and Caicos Islands ", add
lab def zzz  798 "Tuvalu ", add
lab def zzz  800 "Uganda ", add
lab def zzz  804 "Ukraine ", add
lab def zzz  807 "Macedonia ", add
lab def zzz  818 "Egypt ", add
lab def zzz  831 "Guernsey ", add
lab def zzz  832 "Jersey ", add
lab def zzz  833 "Isle of Man  ", add
lab def zzz  834 "Tanzania ", add
lab def zzz  840 "United States ", add
lab def zzz  850 "United States Virgin Islands ", add
lab def zzz  854 "Burkina ", add
lab def zzz  858 "Uruguay ", add
lab def zzz  860 "Uzbekistan ", add
lab def zzz  862 "Venezuela ", add
lab def zzz  876 "Wallis and Futuna ", add
lab def zzz  882 "Samoa ", add
lab def zzz  887 "Yemen ", add
lab def zzz  894 "Zambia ", add
lab def zzz  901 "Cyprus (European Union) ", add
lab def zzz  902 "Cyprus (non-European Union) ", add
lab def zzz  903 "Cyprus Not Otherwise Specified ", add
lab def zzz  911 "Spain (except Canary Islands) ", add
lab def zzz  912 "Canary Islands ", add
lab def zzz  913 "Spain Not Otherwise Specified ", add
lab def zzz  921 "England ", add
lab def zzz  922 "Northern Ireland ", add
lab def zzz  923 "Scotland ", add
lab def zzz  924 "Wales ", add
lab def zzz  925 "Great Britain Not Otherwsie Specified ", add
lab def zzz  926 "United Kingdom Not Otherwise Specified ", add
lab def zzz  931 "Channel Islands Not Otherwise Specified ", add
lab def zzz  951 "Kosovo ", add
lab def zzz  971 "Czechoslovakia Not Otherwise Specified ", add
lab def zzz  972 "Union of Soviet Socialist Republics Not Otherwise Specified ", add
lab def zzz  973 "Yugoslavia Not Otherwise Specified ", add
lab def zzz  981 "Europe Not Otherwise Specified ", add
lab def zzz  982 "Africa Not Otherwise Specified ", add
lab def zzz  983 "Middle East Not Otherwise Specified ", add
lab def zzz  984 "Asia (except Middle East) Not Otherwise Specified ", add
lab def zzz  985 "North America Not Otherwise Specified ", add
lab def zzz  986 "Central America Not Otherwise Specified ", add
lab def zzz  987 "South America Not Otherwise Specified ", add
lab def zzz  988 "Caribbean Not Otherwise Specified ", add
lab def zzz  989 "Antarctica and Oceania Not Otherwise Specified ", add
lab def zzz  991 "At Sea ", add
lab def zzz  992 "In the Air ", add

lab val moplfr07 zzz
lab var moplfr07 "Mother's place of birth, for LSMs born 2007 onward"

tab moplpre92
tab moplfr92
tab moplfr07

*drop intermediate variables
drop scheme1 ZZZ YYY WWW codschem CX last code99 nummopl len
********************************************************************************

