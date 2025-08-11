#!/bin/bash

version=$(grep "^version:" pubspec.yaml | cut -d " " -f2)
echo "当前版本: $version"
new_version=$version
#版本自增
increment_version (){
  declare -a part=( ${1//\./ } )
  declare    new
  declare -i carry=1
  for (( CNTR=${#part[@]}-1; CNTR>=0; CNTR-=1 )); do
    len=${#part[CNTR]}
    new=$((part[CNTR]+carry))
    [ ${#new} -gt $len ] && carry=1 || carry=0
    [ $CNTR -gt 0 ] && part[CNTR]=${new: -len} || part[CNTR]=${new}
  done
  new="${part[*]}"
  new_version=$(echo -e "${new// /.}")
}
increment_version $version
echo "即将发布版本: $new_version"
sed -i "" "s/^version: .*/version: $new_version/" pubspec.yaml

export http_proxy=http://127.0.0.1:61725;
export https_proxy=http://127.0.0.1:61725;
#flutter packages pub publish --dry-run
flutter packages pub publish --server=https://pub.dartlang.org

if [ $? -eq 0 ]; then
  echo "推送成功."
  exit 0
else
  echo "推送失败，回滚版本到:$version."	
  sed -i "" "s/^version: .*/version: $version/" pubspec.yaml
  exit 1
fi
