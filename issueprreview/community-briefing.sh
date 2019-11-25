#!/bin/bash
export myfolder="$HOME/DEVEL/RH/syseng"
mkdir -p $myfolder

DATE="$1"

if [ "${DATE}" == "" ]; then
    echo "Provide date as 2019-06-01 as first argument"
    DATE="$(date -d 'last Thursday - 1 day' +%F)"
fi

echo -e "Weekly report up-to: $DATE\n" |tee -a weekly-report.log

# Prepare GHI
rm -Rf ghi
git clone https://github.com/stephencelis/ghi.git
PATH="`pwd`/ghi:$PATH"

(for repo in kubevirt/demo kubevirt/community kubevirt/kubevirt-tutorial kubevirt/cloud-image-builder kubevirt/katacoda-scenarios metal3-io/metal3-io.github.io kubevirt/kubevirt.github.io; do
    cd $myfolder
    rm -Rf $repo > /dev/null 2>&1
    git clone "https://github.com/$repo" "$repo" > /dev/null 2>&1
    cd $repo
    echo -e "\n[ $repo | https://github.com/$repo ]"
    echo " - PR closed: $(ghi list --since ${DATE} -s closed -p|grep -v "^#" |grep -v None|wc -l)"
    ghi list --since ${DATE} -s closed -p 2>&1|grep -v "^#" |grep -v None|grep -v Ignoring|awk -v REPO="$repo" '/[0-9]+/ {print "    ** ["$1"|https://github.com/" REPO "/issues/" $1 "]"$0}'
    echo " - Issue closed: $(ghi list --since ${DATE} -s closed -P|grep -v "^#"|grep -v None|wc -l )"
    ghi list --since ${DATE} -s closed -P 2>&1|grep -v "^#" |grep -v None|grep -v Ignoring|awk -v REPO="$repo" '/[0-9]+/ {print "    ** ["$1"|https://github.com/" REPO "/issues/" $1 "]"$0}'
    echo " - Still open PR's"
    ghi list -s open -p 2>&1|grep -v "^#" |grep -v Ignoring|awk -v REPO="$repo" '/[0-9]+/ {print "    ** ["$1"|https://github.com/" REPO "/issues/" $1 "]"$0}'
    echo " - Still open Issues"
    ghi list -s open -P 2>&1|grep -v "^#" |grep -v Ignoring|awk -v REPO="$repo" '/[0-9]+/ {print "    ** ["$1"|https://github.com/" REPO "/issues/" $1 "]"$0}'
done
) 2>&1|grep -v Ignoring |grep -v "Insecure world writable dir"|tee -a weekly-report.log
