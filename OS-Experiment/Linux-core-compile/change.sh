for each in $1/*
do
	#文件夹，不改名
	if [ -d $each ]; then
		echo "$each is a directory."
	#文件，改名
	elif [ -f $each ]; then
		echo "$each is a normal file."
		#通配符判断是否已经有日期后缀
		if [[ $each == *-20[0-9][0-9]-[012][0-9]-[0123][0-9]-[012][0-9]-[0-5][0-9]-[0-5][0-9] ]]; then
			echo "$each >> ${each%%-*}-`date +%Y-%m-%d-%H-%M-%S`"			
			mv $each ${each%%-*}-`date +%Y-%m-%d-%H-%M-%S`
		else
			echo "$each >> $each-`date +%Y-%m-%d-%H-%M-%S`"
			mv $each $each-`date +%Y-%m-%d-%H-%M-%S`
		fi
	fi
done
