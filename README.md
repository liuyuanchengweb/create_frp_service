# **一键配置和管理 frp 服务的脚本**

简介：这是一个简单而实用的 Bash 脚本，可帮助您一键配置和管理 frp 服务。通过该脚本，您可以轻松地创建 frp 的服务文件，并使用 systemctl 命令启动、停止、重启和重新加载 frp 服务配置文件。

**正文：**

Frp 是一款功能强大的反向代理工具，用于将外部流量映射到内部网络中的服务。但是官方提供的安装包中没有服务管理，从而导致对程序的运行管理相对要麻烦一些。为了简化 frp 服务的配置和管理过程，使用一个 Bash 脚本，该脚本可以自动创建 frp 的服务文件，并提供了一些常用的 systemctl 命令用于管理 frp 服务。

## 前提条件

1. 您的系统需要安装了 Bash shell。
2. frp 已经在系统中正确安装并设置好路径。脚本中使用 `find` 命令来查找 frpc 和 frps 的可执行文件和配置文件，因此需要确保这些文件在系统中存在。
3. 适当的权限。运行脚本需要足够的权限来创建和修改系统服务文件 `/etc/systemd/system/frpc.service` 和 `/etc/systemd/system/frps.service`。
4. 对 systemd 和 systemctl 命令的了解。脚本使用 systemctl 命令来启动、停止、重启和重新加载 frp 服务。

请确保在运行脚本之前满足上述要求，并谨慎使用脚本来配置和管理 frp 服务。

## 快速使用

~~~bash
# 安装脚本
curl -O https://raw.githubusercontent.com/liuyuanchengweb/create_frp_service/main/create_frp_service.sh
# 或者
wget https://raw.githubusercontent.com/liuyuanchengweb/create_frp_service/main/create_frp_service.sh
# 或者
curl -O https://gitee.com/useryc/create_frp_service/raw/main/create_frp_service.sh
# 或者
wget https://gitee.com/useryc/create_frp_service/raw/main/create_frp_service.sh
# 给脚本添加执行权限
chmod +x create_frp_service.sh
# 执行脚本
./create_frp_service.sh
~~~

## 脚本实现

1. 首先，通过`find`命令查找系统中的特定文件，例如`frpc`、`frpc.ini`、`frps`和`frps.ini`的路径，并将结果存储在相应的变量中。
2. 接下来，定义了两个函数`frpc_service`和`frps_service`，分别用于创建`frpc.service`和`frps.service`的配置文件。
3. 在`frpc_service`函数中，首先检查是否已经存在`frpc.service`文件，如果存在则输出提示信息；如果不存在，则检查`frpc`和`frpc.ini`文件是否存在，如果存在则使用`cat`命令将`frpc.service`的配置内容写入文件`/etc/systemd/system/frpc.service`中，并输出创建成功的提示信息。
4. 在`frps_service`函数中，同样检查是否已经存在`frps.service`文件，如果存在则输出提示信息；如果不存在，则检查`frps`和`frps.ini`文件是否存在，如果存在则使用`cat`命令将`frps.service`的配置内容写入文件`/etc/systemd/system/frps.service`中，并输出创建成功的提示信息。
5. 最后，定义了一个`load_frp`函数，该函数调用了`frpc_service`和`frps_service`函数，然后使用`systemctl daemon-reload`命令重新加载systemd的配置文件。最后输出配置完成和相关命令的提示信息。

总体来说，该脚本的实现机制是根据特定文件的存在与否创建相应的服务配置文件，然后通过systemd命令进行服务管理。

脚本代码：

~~~bash
#! /bin/bash

frpc=$(find / -name "frpc")
frpc_ini=$(find / -name "frpc.ini")
frps=$(find / -name "frps")
frps_ini=$(find / -name "frps.ini")
frpc_service="/etc/systemd/system/frpc.service"
frps_service="/etc/systemd/system/frps.service"

frpc_service(){
    if [ -f $frpc_service ];then
        echo -e "frpc服务文件以存在$frpc_service"
    else
        if [ -f $frpc ] && [ -f $frpc_ini ];then
            cat > /etc/systemd/system/frpc.service << EOF
[Unit]
Description=Frpc Service
After=network.target

[Service]
ExecStart=$frpc -c $frpc_ini
ExecReload=/bin/kill -HUP
Restart=always

[Install]
WantedBy=multi-user.target
EOF
            echo -e "创建frpc.service文件成功，文件路径：$frpc_service"
        else
            echo -e "没有找到frpc程序的路径和frpc.ini文件的路径"

        fi
    fi
}

frps_service(){
    if [ -f $frps_service ];then
        echo -e "frps服务文件以存在$frps_service"
    else
        if [ -f $frps ] && [ -f $frps_ini ];then
            cat > /etc/systemd/system/frps.service << EOF
[Unit]
Description=Frps Service
After=network.target

[Service]
ExecStart=$frps -c $frps_ini
ExecReload=/bin/kill -HUP
Restart=always

[Install]
WantedBy=multi-user.target
EOF
            echo -e "创建frpc.service文件成功，文件路径：$frpc_service"
        else
            echo -e "没有找到frps程序的路径和frps.ini文件的路径"

        fi
    fi
}


load_frp(){
    frpc_service 
    frps_service
    systemctl daemon-reload
    echo -e "配置frp服务完成"
    echo -e "使用systemctl enable --now frpc.service 命令设置frpc开机自动启动并立即启动服务"
    echo -e "使用systemctl status frpc.service 命令查看frpc服务状态信息"
    echo -e "使用systemctl stop frpc.service 停止 frpc 服务"
    echo -e "使用systemctl disable frpc.service 将 frpc 服务从开机自动启动中移除"
    echo -e "使用systemctl restart frpc.service 将 frpc 服务重新启动"
    echo -e "使用systemctl reload frpc.service 重新加载frpc的配置文件"
    echo -e "使用systemctl enable --now frps.service 命令设置frps开机自动启动并立即启动服务"
    echo -e "使用systemctl status frps.service 命令查看frps服务状态信息"
    echo -e "使用systemctl stop frps.service 停止 frps 服务"
    echo -e "使用systemctl disable frps.service 将 frps 服务从开机自动启动中移除"
    echo -e "使用systemctl restart frps.service 将 frps 服务重新启动"
    echo -e "使用systemctl reload frps.service 重新加载frps的配置文件"
}
load_frp

~~~

## 使用方法

按照以下步骤使用：

1. 复制以上代码到自己的系统中创建sh脚本文件

2. 赋予脚本执行权限`chmod +x sh脚本文件 `

3. 执行脚本`./sh脚本文件`

4. 等待脚本执行完成，输出相应的结果

## 注意事项

在使用该脚本时，需要注意以下几个事项：

1. 权限：确保以具有足够权限的用户身份运行该脚本，以便能够创建和修改系统文件。

2. 文件路径：脚本中使用了`find`命令来查找特定文件的路径，请确保在使用脚本之前，已经正确安装了相关软件，并且这些文件存在于系统中。如果文件路径不正确或文件不存在，脚本将无法正常运行。

3. 脚本路径：将脚本保存到合适的位置，并赋予可执行权限。可以根据需要修改脚本中的文件路径和服务配置信息。

4. 冲突检查：在创建服务配置文件时，脚本会检查目标路径是否已经存在相应的文件。如果已经存在，则会输出相应的提示信息。这可以避免重复创建或覆盖已有的配置文件。

5. systemd服务管理：脚本中使用了`systemctl`命令来管理服务，例如启动、停止、重新加载和设置开机自动启动等。确保已经正确安装了systemd，并理解`systemctl`命令的使用方法。

6. 注意事项提示：脚本在最后输出了一系列使用`systemctl`命令的提示信息，提醒用户如何操作和管理已配置的服务。请按照提示信息执行相应的命令。

请注意，在使用脚本之前，建议先仔细阅读脚本的代码，并根据实际情况进行适当的修改和调整。确保理解脚本的功能和运行机制，以便正确地使用和管理frp服务。

