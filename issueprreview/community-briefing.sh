#!/bin/bash

export myfolder="/home/iranzo/DEVEL/RH/syseng"

DATE="$1"

if [ "${DATE}" == "" ]; then
    echo "Provide date as 2019-06-01 as first argument"
    exit 1
fi

(for repo in kube/demo kube/community kube/kubevirt-tutorial kube/cloud-image-builder kube/katacoda-kubevirt metal3/metal3-io.github.io kube/kubevirt.github.io; do
    cd $myfolder
    cd $repo
    echo -e "\n$repo"
    echo " - PR closed: $(ghi list --since ${DATE} -s closed -p|grep -v "^#" |grep -v None|wc -l)"
    ghi list --since ${DATE} -s closed -p 2>&1|grep -v "^#" |grep -v None|grep -v Ignoring|awk -v REPO="$repo" '/[0-9]+/ {print "    ** ["$1"|https://github.com/" REPO "/issues/" $1 "]"$0}'
    echo " - Issue closed: $(ghi list --since ${DATE} -s closed -P|grep -v "^#"|grep -v None|wc -l )"
    ghi list --since ${DATE} -s closed -P 2>&1|grep -v "^#" |grep -v None|grep -v Ignoring|awk -v REPO="$repo" '/[0-9]+/ {print "    ** ["$1"|https://github.com/" REPO "/issues/" $1 "]"$0}'
    echo " - Still open PR's"
    ghi list -s open -p 2>&1|grep -v "^#" |grep -v Ignoring|awk -v REPO="$repo" '/[0-9]+/ {print "    ** ["$1"|https://github.com/" REPO "/issues/" $1 "]"$0}'
    echo " - Still open Issues"
    ghi list -s open -P 2>&1|grep -v "^#" |grep -v Ignoring|awk -v REPO="$repo" '/[0-9]+/ {print "    ** ["$1"|https://github.com/" REPO "/issues/" $1 "]"$0}'
done
) 2>&1|grep -v Ignoring
