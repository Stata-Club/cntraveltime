{smcl}
{* 25Aug2017}{...}
{hi:help cntraveltime}
{hline}

{title:Title}

{phang}
{bf:cntraveltime} {hline 2} 
This Stata module helps to extract the time needed for traveling between two locations specified from Baidu Map API(http://api.map.baidu.com)

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:cntraveltime}{cmd:,} {start_lat(varname) start_lng(varname)|startaddr(varname)} {end_lat(varname) end_lng(varname)|endaddr(varname)} [{it:options}]

Extracts the time spent in traveling and other relevant informations with BaiduMap API, conditional on a given travel mode.


{marker description}{...}
{title:Description}

{pstd}
Baidu Map API is widely used in China.
{cmd:cntraveltime} use Baidu Map API to extract the time traveling from one location to another.
Forthemore,it can also extract the detailed information about the route of traveling and corresponding longitude & latitude of the two locations.
Before using this command,a Baidu key from Baidu Map API is needed.
 A typical Baidu key is an alphanumeric string. The option baidukey(string) is actually not optional.
  If you have a Baidu key, which is, say CH8eakl6UTlEb1OakeWYvofh, the baidukey option must be specified as baidukey(CH8eakl6UTlEb1OakeWYvofh). 
  You can get a secret key from Baidu Map's open platform (http://lbsyun.baidu.com). 
  The process normally will take 3-5 days after you submit your application online.
  Following information can be extract when using {cmd:cntraveltime}, conditional on the travel mode specified.
  (1) time spent for drving from one location to another.
  (2) detail inforamtion of route chosen.
  {p_end}

{pstd}
{cmd:cntraveltime} require Stata version 14 or higher. {p_end}

{marker options}{...}
{title:options for cntraveltime}

{dlgtab:Credentials(required)}

{phang}
{opt baidukey(string)} is required before using this command. 
You can get a secret key from Baidumap open platform(http://lbsyun.baidu.com). 
The process normally will take 3-5 days after you submit your application online. {p_end}

{phang}
{opt start_lat(varname)} & {opt start_lng(varname)} specify the longitude and latitude of the origin
location.  
These cannot be used with {opt startaddr(varname)}.
{opt start_lat(varname)} & {opt start_lng(varname)} or {opt startaddr(varname)} is required.{p_end}

{phang}
{opt end_lat(varname)} & {opt end_lng(varname)} specify the longitude and latitude of the destination
location.
These cannot be used with {opt endaddr(varname)}.
{opt end_lat(varname)} & {opt end_lng(varname)} or {opt endaddr(varname)} is required.{p_end}


{phang}
{opt startaddr(varname)} & {opt endaddr(varname)} specifies the variable holding the plain text address of the origin location and destination location.{p_end}


{dlgtab:Respondent preference}

{phang}
{opt instruction:} :If users need detail information about the route chosen, option {opt instruction} helps.
The default is not to show this information.{p_end}

{phang}
{opt xml:} :If users need the information of source code provided by BaiduMap, {opt xml} will return it in xml format.
The default is not to show this information.{p_end}

{phang}
{opt detail:} :If users need all the detailed information, use {opt detail} option.
{p_end}

{dlgtab:Public transportation}
{phang}
{opt public(string)} can change the travel mode.
When the option {opt public} is empty, the default is drving by car that is called private-mode.
Once the option {opt public} is not empty, command will use public-mode.
There are some specific options of public-mode given below.
{p_end}

{pmore}
In BaiduMap API, there are two traveling types in public-mode.
The first type is {opt inter-city} that means the starting address and the terminal address users specify are in different city.
The second type is {opt in-city} that means the starting address and the terminal address users specify are in same city.
These two types will be automatic recognition by Baidu Map.{p_end}

{pmore}
{opt plane:} If the type of address is {opt inter-city} in public-mode, {opt plane} specifies the preference that people prefer to travel by plane.
For example, public(plane).
In the {opt inter-city} type, default is {opt train}.{p_end}

{pmore}
{opt bus:} If the type of address is {opt inter-city} in public-mode, {opt bus} specifies the preference that people prefer to travel by bus.
In the {opt inter-city} type, default is {opt train}.{p_end}

{pmore}
{opt straight:} If the type of address is {opt in-city} in public-mode, {opt straight} specifies the preference that users transfer as less as possible.{p_end}

{pmore}
{opt nowalk:} If the type of address is {opt in-city} in public-mode, {opt nowalk} specifies the preference that users want to walk as less as possible in this traveling.{p_end}

{pmore}
{opt shorttime:} If the type of address is {opt in-city} in public-mode, {opt shorttime} specifies the preference that users want to go to the destination as fast as possible.{p_end}

{pmore}
By the way, if the option users specify is other word, command will be executed in default.
In the {opt inter-city} type, default is {opt train}.
In the {opt in-city} type, default is intelligently recommended by Baidu Map.
It must be point out that the {opt distance} is inaccurate in {opt inter-city} type because the distance of traveling by train and plane will be ignore in BaiduMap.{p_end}

{marker example}{...}
{title:Example}

{pstd}
Input the address

{phang}
{stata `"clear"'}
{p_end}
{phang}
{stata `"set more off"'}
{p_end}
{phang}
{stata `"input str100 startaddress str100 endaddress "'}
{p_end}
{phang}
{stata `""湖北省武汉市洪山区中南财经政法大学" "北京市北京大学" "'}
{p_end}
{phang}
{stata `""湖北省武汉市武昌区政府" "湖北省武汉市南湖大道中南财经政法大学""'}
{p_end}
{phang}
{stata `""陕西省西安市雁塔区大雁塔" "陕西省西安市碑林区碑林博物馆" "'}
{p_end}
{phang}
{stata `""安徽省淮北市相山区相山公园" "江苏省徐州市徐州东站" "'}
{p_end}
{phang}
{stata `"end"'} 
{p_end}

{pstd}
Extracts the duration and distance of drving between the two place

{phang}
{stata `"cntraveltime, baidukey(your secret key) startaddr(startaddress) endaddr(endaddress)"'}
{p_end}
{phang}
{stata `"list duration distance"'}
{p_end}

{pstd}
Extracts the detail information of drving between the two place.

{phang}
{stata `"cntraveltime, baidukey(your secret key) startaddr(startaddress) endaddr(endaddress) detail"'}
{p_end}
{phang}
{stata `"list instructions duration distance  xmlcode "'}
{p_end}


{pstd}
Extracts the instructions of traveling between the two place by plane

{phang}
{stata `"cntraveltime, baidukey(your secret key) startaddr(startaddress) endaddr(endaddress) instruction public(plane)"'}
{p_end}
{phang}
{stata `"list instructions duration distance "'}
{p_end}

{pstd}
Input the address

{phang}
{stata `"clear"'}
{p_end}
{phang}
{stata `"set more off"'}
{p_end}
{phang}
{stata `"input double startlat double startlng double endlat double endlng"'}
{p_end}
{phang}
{stata `"28.18561 112.95033 39.99775 116.31616"'}
{p_end}
{phang}
{stata `"43.85427 125.30057 28.18561 112.95033"'}
{p_end}
{phang}
{stata `"31.85925 117.21600 33.01379 119.36848"'}
{p_end}
{phang}
{stata `"end"'} 
{p_end}

{pstd}
Extracts the detail information of drving between the two place.

{phang}
{stata `"cntraveltime, baidukey(your secret key) start_lat(startlat) start_lng(startlng) end_lat(endlat) end_lng(endlng) detail"'}
{p_end}
{phang}
{stata `"list instructions duration distance "'}
{p_end}


{title:Author}

{pstd}Chuntao LI{p_end}
{pstd}School of Finance, Zhongnan University of Economics and Law{p_end}
{pstd}Wuhan, China{p_end}

{pstd}Yuan Xue{p_end}
{pstd}School of Finance, Zhongnan University of Economics and Law{p_end}
{pstd}Wuhan, China{p_end}

{pstd}Xueren Zhang{p_end}
{pstd}School of Finance, Zhongnan University of Economics and Law{p_end}
{pstd}Wuhan, China{p_end}


