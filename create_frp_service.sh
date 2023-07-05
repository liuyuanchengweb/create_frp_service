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
            echo -e "创建frps.service文件成功，文件路径：$frps_service"
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
