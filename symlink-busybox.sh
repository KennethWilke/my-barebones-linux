cd initfs/bin
for i in `./busybox --list`
do
	ln -s busybox $i
done
