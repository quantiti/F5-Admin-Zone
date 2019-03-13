#/bin/bash
pool=$2
echo "VS,VS IP,Policies,PoolName,PoolMember">$pool
while read -r line; do
	row="$line"
	#if empty string
	if [ -z "$line" ]
	then 
		echo " ">>$pool
		echo "empty VS!"
		continue
	fi
	echo "Getting information for virutal server $line"
	###get pool name
	vs=`tmsh list ltm virtual $line`	
	###get VS IP : PORT
	read -r -a myarray <<< $vs
	haspolicy=0
	for index in "${!myarray[@]}"		###doc toan bo cac gia tri cua VS vao trong mang, moi mang la 1 gia tri, voi moi gia tri nay thuc hien so sanh tim gia tri can trich xuat
	do
		if [ ${myarray[index]} == "destination" ]
		then
			row="$row,${myarray[index+1]}"
			#echo $row
		fi
		if [ ${myarray[index]} == "policies" ]
		###get policies applies to the VS
		###policies { pol1 { } pol2 { } }
                then
			haspolicy=1
                        i=2
                        pol=""
                        while [ "${myarray[index+i]}" != "}" ]; do
			#	polname=`echo ${myarray[index+i]}|tr -d '{'|tr -d '}'|tr -d ','|tr -d ' '`
				polname=`echo ${myarray[index+i]}`
                                pol="$pol $polname"
                                i=$i+3 ###next 3 step including: polname { } 
                        done
                        row="$row,$pol"   ###adding policies to row
			#echo "GOT POL $pol $haspolicy"
                fi
		if [ ${myarray[index]} == "pool" ]
                then	
			#echo "CHECK IN POOL $haspolicy"
			if [ $haspolicy == "0" ]; then
                        	row="$row,"
				#echo "DO NOT HAVE POLICY $row"
                	fi
                        row="$row,${myarray[index+1]}"
                        #echo $row
			poolmember=`tmsh list ltm pool ${myarray[index+1]} | grep : | tr -d '{'`
			row="$row,$poolmember"
			#echo $row
                fi
	done
	#echo $row
        echo $row>>$pool
	unset myarray
done < $1
