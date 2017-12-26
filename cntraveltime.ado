program cntraveltime
version 14.0
syntax, baidukey(string) [start_lat(string) start_lng(string) startaddr(string) end_lat(string) end_lng(string) endaddr(string)  public(string) instruction xml detail]



if ("`startaddr'" == "" & "`start_lat'"=="") | ("`startaddr'"=="" & "`start_lng'"==""){
	di in red "error: You must specify either lat&lng coordinates or an string address"
	exit
}

if ("`endaddr'" == "" & "`end_lat'"=="") | ("`endaddr'"=="" & "`end_lng'"==""){
	di in red "error: You must specify either lat&lng coordinates or an string address"
	exit
}



quietly{
tempvar routestring swork ework baidumap blank h m s km meter
gen `baidumap'=""
gen `routestring'=""
gen realroute=""

gen startlatitude=""
gen startlongitude=""
gen endlatitude=""
gen endlongitude=""
gen tempguide=""
gen tempguide2=""
gen tempnum=""
gen tempnum2=""
gen duration=""
gen distance=""
gen xmlcode=""

local like=0
local incity=0
if "`public'"=="straight"{
		local incity 1
	}
 if "`public'"=="nowalk"{
		local incity 2

	}	
if "`public'"=="shorttime"{
		local incity 4

	}
if "`public'"=="plane" { 
		local like  1
	}
if "`public'"== "bus" { 
		local like 2
	}




	if "`start_lat'"=="" & "`startaddr'"!=""{
		forvalues i = 1/`=_N' {
			replace `baidumap' = fileread(`"http://api.map.baidu.com/geocoder/v2/?output=json&ak=`baidukey'&address=`=startaddr[`i']'"') in `i'
			replace startlongitude = ustrregexs(1) if ustrregexm(`"`=`baidumap'[`i']'"',`""lng":(\d{2,3}\.\d{5}).*?,"')  in `i'
 			replace startlatitude  = ustrregexs(1) if ustrregexm(`"`=`baidumap'[`i']'"',`""lat":(\d{2}\.\d{5}).*?\}"')  in `i'
			if index(`baidumap'[`i'],"AK有误请检查再重试") {
				di in red "error: please check your baidukey"
				continue,break
			}		
		}	
	}
	else if "`start_lat'"!="" & "`startaddr'"==""{
	//	di in red "now is latlng mode"
	 	tostring `start_lng' ,replace
 		tostring `start_lat' ,replace
		replace startlongitude =`start_lng' 
 		replace startlatitude  =`start_lat'	
 		destring `start_lng' ,replace
 		destring `start_lat' ,replace

	}




		if "`end_lat'"=="" & "`endaddr'"!=""{
				forvalues i = 1/`=_N' {
		replace `baidumap' = fileread(`"http://api.map.baidu.com/geocoder/v2/?output=json&ak=`baidukey'&address=`=endaddr[`i']'"') in `i'
          //	di in red `"http://api.map.baidu.com/geocoder/v2/?output=json&ak=`baidukey'&address=`=`ework'[`i']'"'
		replace endlongitude = ustrregexs(1) if ustrregexm(`"`=`baidumap'[`i']'"',`""lng":(\d{2,3}\.\d{5}).*?,"')  in `i'
 		replace endlatitude  = ustrregexs(1) if ustrregexm(`"`=`baidumap'[`i']'"',`""lat":(\d{2}\.\d{5}).*?\}"')  in `i'
		if index(`baidumap'[`i'],"AK有误请检查再重试") {
			di in red "error: please check your baidukey"
			continue,break
		}
	}
	
	 }
		else if "`end_lat'"!="" & "`endaddr'"==""{
	//	di in red "now is latlng mode"
		tostring `end_lng' ,replace
 		tostring `end_lat' ,replace
		replace endlongitude =`end_lng'
 		replace endlatitude  =`end_lat'		
 		destring `end_lng' ,replace
 		destring `end_lat' ,replace
	}
	



if "`public'"==""{
	gen instruct=""

  forvalues i = 1/`=_N' {
  // di in red "http://api.map.baidu.com/direction/v1?mode=driving&origin=`=startlatitude[`i']',`=startlongitude[`i']'&destination=`=endlatitude[`i']',`=endlongitude[`i']'&origin_region=&destination_region=&output=json&ak=`baidukey'"
		replace `routestring' = fileread(`"http://api.map.baidu.com/direction/v1?mode=driving&origin=`=startlatitude[`i']',`=startlongitude[`i']'&destination=`=endlatitude[`i']',`=endlongitude[`i']'&origin_region=&destination_region=&ak=`baidukey'"') in `i'	
		replace xmlcode = `routestring'[`i']  in `i'
		 		if index(`routestring'[`i'],"<status>2</status>") {
			di in red "error: please check your address in observation[`i']"
			continue
		}
				if index(`routestring'[`i'],"AK有误请检查再重试") {
			di in red "error: please check your baidukey"
			continue
		}

		}
	}
	else{
		forvalues i = 1/`=_N' {
	//	di in red `"http://api.map.baidu.com/direction/v2/transit?origin=`=startlatitude[`i']',`=startlongitude[`i']'&destination=`=endlatitude[`i']',`=endlongitude[`i']'&page_size=1&trans_type_intercity=`like'&tactics_incity=`incity'&output=json&ak=`baidukey'"'
		replace `routestring' = fileread(`"http://api.map.baidu.com/direction/v2/transit?origin=`=startlatitude[`i']',`=startlongitude[`i']'&destination=`=endlatitude[`i']',`=endlongitude[`i']'&page_size=1&trans_type_intercity=`like'&tactics_incity=`incity'&output=xml&ak=`baidukey'"') in `i'	
				if index(`routestring'[`i'],"没有公交方案") {
			di in red "error:The observation[`i'] can not find the method"
			continue
		}
				if index(`routestring'[`i'],"<status>2</status>") {
			di in red "error: please check your address in observation[`i']"
			continue
		}
				if index(`routestring'[`i'],"AK有误请检查再重试") {
			di in red "error: please check your baidukey"
			continue
		}
		replace xmlcode = `routestring'[`i']  in `i'
		}
	}

replace realroute=ustrregexra(`routestring',"\n","")
replace realroute=ustrregexra(realroute,"\s*","")
replace realroute=ustrregexra(realroute,"<detail>.*?</detail>","")
replace distance=ustrregexs(1) if ustrregexm(realroute,"<distance>(\d+?)<")
replace duration=ustrregexs(1) if ustrregexm(realroute,"<duration>(\d+?)<")
destring duration distance,replace
gen km=(distance-mod(distance,1000))/1000
gen meter=mod(distance,1000)
gen h=(duration-mod(duration,3600))/3600
gen m=(mod(duration,3600)-mod(duration,60))/60
gen s=mod(duration,60)
tostring h m s duration distance km meter,replace
replace duration=h+"小时"+m+"分钟"+s+"秒"
replace distance=km+"公里"+meter+"米"
drop h m s km meter

if "`public'"==""{
	local j 0
	quietly{
		forvalues i= 1/`=_N'{
			while ustrregexm("`=realroute[`i']'","tion><instructions>(.*?)</ins") {
				replace tempguide2=ustrregexs(1) if ustrregexm("`=realroute[`i']'","<instructions>(.*?)</ins") in `i' //抓取新一段instructions
				replace tempnum2=ustrregexs(1) if ustrregexm("`=tempguide2[`i']'","(\d*\.\d)")  in `i'  //提取其中的 数字信息 （字符串）
				replace tempguide2=ustrregexra("`=tempguide2[`i']'","(\d*\.\d)","number")   in `i' //将该信息中的具体数字替换为 number

    			if  ("`=tempguide[`i']'"=="`=tempguide2[`i']'"){
					local j=`=real("`=tempnum[`i']'")' + `=real("`=tempnum2[`i']'")'
 					replace tempnum = "`j'" in `i'             
				}
				else{
					replace tempnum=ustrregexs(1) if ustrregexm("`=tempnum[`i']'","^(\d*\.\d)") in `i'
					replace tempguide=ustrregexra("`=tempguide[`i']'","number","`=tempnum[`i']'")  in `i'
					replace instruct="`=instruct[`i']'"+"，"+ "`=tempguide[`i']'"  in `i'
					replace tempnum="`=tempnum2[`i']'" in `i'
					replace tempguide="`=tempguide2[`i']'" in `i'
				}

				replace realroute=ustrregexrf("`=realroute[`i']'","^.*?tion><instructions>","") in `i'
			}

			replace tempguide=ustrregexra("`=tempguide[`i']'","number","`=tempnum[`i']'") in `i'
			replace instruct="`=instruct[`i']'" +"，"+"`=tempguide[`i']'"  in `i'
		}
	}

	replace instruct=substr(instruct,7,.)
	replace instruct=ustrregexra(instruct,"&lt;/?b&gt;|&lt;br/?&gt;|&lt;fontcolor=&quot;0xDC3C3C&quot;&gt;|&lt;/font&gt;","")
	rename instruct instructions
}
else{
	local instruct instructions
	gen `instruct'=""
	gen startlng=""
	gen startlat=""
	gen endlng=""
	gen endlat=""
	gen firstsen=""

	forvalues i= 1/`=_N'{
		while ustrregexm(`"`=realroute[`i']'"',"<instructions>(.*?)</ins") {
			replace firstsen=ustrregexs(1) if ustrregexm(`"`=realroute[`i']'"',"<instructions>(.*?)</ins") in `i'
			if ustrregexm("`=firstsen[`i']'","^步"){
				replace startlng =ustrregexs(1) if ustrregexm(`"`=realroute[`i']'"',"<start_location><lng>(.*?)<") in `i'
				replace startlat =ustrregexs(1) if ustrregexm(`"`=realroute[`i']'"',"<start_location>.*?<lat>(.*?)<") in `i'
				replace endlng=ustrregexs(1) if ustrregexm(`"`=realroute[`i']'"',"<end_location><lng>(.*?)<")	in `i'
				replace endlat=ustrregexs(1) if ustrregexm(`"`=realroute[`i']'"',"<end_location>.*?<lat>(.*?)<")	in `i'

				if (real("`=endlng[`i']'")-real("`=startlng[`i']'"))>(real("`=endlat[`i']'")-real("`=startlat[`i']'")) & ((real("`=endlng[`i']'")-real("`=startlng[`i']'")))+(real("`=endlat[`i']'")-real("`=startlat[`i']'"))>0 {
					replace `instruct'=`"`=`instruct'[`i']'"'+"，向东"+ustrregexs(1) if ustrregexm(`"`=realroute[`i']'"',"<instructions>(.*?)<")	in `i'
				}

				if  (real("`=endlng[`i']'")-real("`=startlng[`i']'"))>(real("`=endlat[`i']'")-real("`=startlat[`i']'")) & ((real("`=endlng[`i']'")-real("`=startlng[`i']'")))+(real("`=endlat[`i']'")-real("`=startlat[`i']'"))<0{
					replace `instruct'=`"`=`instruct'[`i']'"'+"，向南"+ustrregexs(1) if ustrregexm(`"`=realroute[`i']'"',"<instructions>(.*?)<")	in `i'
				}
				if  (real("`=endlng[`i']'")-real("`=startlng[`i']'"))<(real("`=endlat[`i']'")-real("`=startlat[`i']'")) & ((real("`=endlng[`i']'")-real("`=startlng[`i']'")))+(real("`=endlat[`i']'")-real("`=startlat[`i']'"))<0{
					replace `instruct'=`"`=`instruct'[`i']'"'+"，向西"+ustrregexs(1) if ustrregexm(`"`=realroute[`i']'"',"<instructions>(.*?)<")	in `i'
				}
				if  (real("`=endlng[`i']'")-real("`=startlng[`i']'"))<(real("`=endlat[`i']'")-real("`=startlat[`i']'")) & ((real("`=endlng[`i']'")-real("`=startlng[`i']'")))+(real("`=endlat[`i']'")-real("`=startlat[`i']'"))>0{
					replace `instruct'=`"`=`instruct'[`i']'"'+"，向北"+ustrregexs(1) if ustrregexm(`"`=realroute[`i']'"',"<instructions>(.*?)<")	in `i'
				}
			}
			if ustrregexm("`=firstsen[`i']'","^步")==0 & ustrregexm(`"`=firstsen[`i']'"',".") {
				replace `instruct'=`"`=`instruct'[`i']'"'+"，"+ustrregexs(1) if ustrregexm(`"`=realroute[`i']'"',"<instructions>(.*?)<")	in `i'
			}
			replace realroute=ustrregexrf(`"`=realroute[`i']'"',".*?<instructions>","") in `i'
		}
		if "`=`instruct'[`i']'"!=""{
			replace `instruct'=`"`=`instruct'[`i']'"'+"到达终点" in `i'
		}
		else{
			replace `instruct'="...None" in `i'
		}
	}
replace `instruct'=substr(`instruct',4,.)
drop  startlng startlat endlng endlat firstsen
}


drop startlatitude startlongitude endlatitude endlongitude

drop realroute tempnum tempnum2 tempguide tempguide2 
if "`detail'"=="detail"{
	exit
}


if "`instruction'"!="instruction"{
	drop instructions
}
if "`xml'"!="xml"{
	drop xmlcode
}
}
end
