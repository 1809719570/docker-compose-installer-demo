#!/bin/bash

# 获取脚本自身的路径
SOURCE="${BASH_SOURCE[0]}"

# 解决符号链接问题，直到文件不再是符号链接为止
while [ -h "$SOURCE" ]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )" # 获取符号链接所在目录的绝对路径
    SOURCE="$(readlink "$SOURCE")" # 读取符号链接指向的目标
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # 如果符号链接是相对路径，则将其转换为绝对路径
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )" # 获取脚本所在目录的绝对路径

## 定义版本匹配的正则表达式
#VERSION_REG="{docker-compose-demo-{ce|ee}:beta|docker-compose-demo-{ce|ee}:latest|docker-compose-demo-{ce|ee}:v{version}}"

version="latest"
# 检查是否提供了版本参数
# -z 判断是否为空 -n 是否非空
if [ -n "$1" ]; then
  # 将第一个参数赋值给version变量
  version=$1
fi


## 检查提供的版本参数是否符合正则表达式
#if [[ $version =~ ^(docker-compose-demo-(ce|ee):(beta|latest|v[0-9]+\.[0-9]+\.[0-9]+))$ ]]; then
#    echo "匹配的版本: $version"
#else
#    echo "版本参数不符合模式 $VERSION_REG。"
#    exit 1 # 退出脚本，并返回错误码1
#fi

echo "版本是: $version"

# 将版本信息写入depends/.env文件
echo "VERSION=$version" > depends/.env

# 执行Python初始化脚本
python3 init.py
echo "安装已完成。"