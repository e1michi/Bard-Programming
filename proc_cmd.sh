#word=予約
#echo '{"obj":[["会議室","予約"],["会議室","予約"],["予約","会議室"],["予約"]]}' \
#		| jq -c -r "[.obj | .[] | if .[length - 1] != \"$word\" then .[:length] elif length > 1 then .[:length - 1] else empty end]"
#exit

find_files() {
	conds=`echo "$1" \
		| jq -c -r '.[]'`
	conds=資料
#	conds=$1
#	shift
#	for cond in $*
#	do
#		conds="$conds*$cond"
#	done
	egrep -i "$conds" file_list.txt \
		| head -5 \
		| while read line
		do
			basename "$line" | sed 's/ /\&sp;/g'
		done
}

#find_files '[["会議"],["資料"]]'
#exit

print_to() {
	to=`echo $1 | jq -c -r .to`
	if [ "$to" != "[]" ]; then
		echo -n "$toに"
	fi
}

print_obj() {
	obj=`echo $1 \
		| jq -c -r "[.obj | .[] | if .[length - 1] != \"$2\" then .[:length] elif length > 1 then .[:length - 1] else empty end]"`
	if [ "$obj" != "[]" ]; then
		echo -n "$objを"
	fi
}

print_about() {
	about=`echo $1 | jq -c -r .about`
	if [ "$about" != "[]" ]; then
		echo -n "$aboutについて"
	fi
}

print() {
	print_about "$1"
	print_to "$1"
	print_obj "$1" "$2"
}

#echo "$1" > proc_cmd_params.txt
cmd=`echo "$1" | jq -c -r .cmd`
params=`echo "$1" | jq -c -r .params`

case $cmd in
phone)
	word=電話
	print "$params" $word
	echo "$wordしました。"
	;;
mail)
	word=メール
	print "$params" $word
	echo "$wordしました。"
	;;
entry)
	word=登録
	print "$params" $word
	echo "$wordしました。"
	;;
copy)
	word=コピー
	print "$params" $word
	echo "$wordしました。"
	;;
confirm)
	word=確認
	print "$params" $word
	echo "$wordしました。"
	;;
print)
	word=印刷
	print "$params" $word
	echo "$wordしました。"
	;;
announce)
	word=周知
	print "$params" $word
	echo "$wordしました。"
	;;
handover)
	word=引継ぎ
	print "$params" $word
	echo "$wordしました。"
	;;
report)
	word=報告
	print "$params" $word
	echo "$wordしました。"
	;;
contact)
	word=連絡
	print "$params" $word
	echo "$wordしました。"
	;;
consult)
	word=相談
	print "$params" $word
	echo "$wordしました。"
	;;
collaborate)
	word=連携
	print "$params" $word
	echo "$wordしました。"
	;;
deploy)
	word=展開
	print "$params" $word
	echo "$wordしました。"
	;;
order)
	word=命令
	print "$params" $word
	echo "$wordしました。"
	;;
explain)
	word=解説
	print "$params" $word
	echo "$wordしました。"
	;;
assist)
	word=支援
	print "$params" $word
	echo "$wordしました。"
	;;
reserve)
	word=予約
	result=`print "$params" $word`
	if [ "$result" = "" ]; then
		echo '指示が曖昧です。'
	else
		echo "$result$wordしました。"
	fi
	;;
find)
	obj=`echo $params | jq -c -r .obj`
	if [ "$obj" = "[]" ]; then
		echo '指示が曖昧です。'
		exit
	fi
	file_list=`find_files $obj`
	if [ "$file_list" = "" ]; then
		echo "$objが見つかりませんでした。"
		exit
	fi
	echo "$objが見つかりました。"
	cnt=1
	for filename in $file_list
	do
		echo "$cnt: $filename"
		cnt=`expr $cnt + 1`
	done
	;;
msg)
	obj=`echo $params | jq -c -r .obj`
	echo "$obj"
	;;
*)
	echo "内容を理解できませんでした。($cmd/$params)"
	;;
esac
