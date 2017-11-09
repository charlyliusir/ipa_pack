#!/bin/bash
# Author charly

#!/bin/bash
# Author charly

WORKSPACENAME=项目空间名称
SCHEMENAME=Scheme 名称
CONFIGURATION=环境名称(Release or Debug)
BRANCHNAME=分支名称(可以不设置
FIRTOCKEN=fir分发平台的登录标识

DATE=`date +%Y%m%d_%H%M`
SOURCEPATH=$( cd "$( dirname $0 )" && pwd)
ARCHIVEPATH=${SOURCEPATH}/AutoBuildIPA/${BRANCHNAME}/${DATE}
IPAPATH=${SOURCEPATH}/AutoBuildIPA/${BRANCHNAME}/${SCHEMENAME}_${DATE}
IPANAME=${SCHEMENAME}.ipa
COMMIT_MSG="测试自动发布" #打包内容

# 切换分支
git checkout ${BRANCHNAME}
if [ $? -ne 0 ]; then
exit 1
fi

# 拉取
git pull

# 执行 pod 命令
# pod update --verbose --no-repo-update

# build xxx
xcodebuild archive \
-workspace ${WORKSPACENAME}.xcworkspace \
-scheme ${SCHEMENAME} \
-configuration ${CONFIGURATION} \
-archivePath ${ARCHIVEPATH}
#CODE_SIGN_IDENTITY="证书"
#PROVISIONING_PROFILE="证书UUID"

if [ -e ${ARCHIVEPATH}.xcarchive ]; then
echo "xcodebuild Successful"
else
echo "erro:Build failed!!"
exit 1 #退出命令执行
fi

# xcrun xxx
xcodebuild -exportArchive \
-archivePath ${ARCHIVEPATH}.xcarchive \
-exportPath ${IPAPATH} \
-exportOptionsPlist exportOptions.plist \
#CODE_SIGN_IDENTITY="证书"
#PROVISIONING_PROFILE="证书UUID"

if [ -e ${IPAPATH}/${IPANAME} ]; then
echo "\n-------------------------\n\n\n"
echo "Configurations! Build Successful!"
echo "\n\n\n-------------------------\n\n"
#open ${IPAPAHT} 打开目录文件
else
echo "\n---------------------------------------------------------------\n"
echo "erro:Create IPA failed!!"
echo "\nPlease check the case of failure and contact developers,thanks!"
echo "Export Error Path : ${IPAPATH}/${IPANAME}"
echo "\n---------------------------------------------------------------\n"
exit 1
fi

if [ -e ${IPAPATH}/${IPANAME} ]; then
fir publish ${IPAPATH}/${IPANAME} -T ${FIRTOCKEN} -c ${COMMIT_MSG}
else
echo "Publish Error : ${IPAPATH}/${IPANAME}"
fi


