#!/bin/bash

# 檢查 nmcli 是否存在
if ! command -v nmcli &> /dev/null; then
    echo "❌ nmcli 未安裝，請先安裝 NetworkManager"
    exit 1
fi

# 取得 Wi-Fi 裝置
device=$(nmcli device status | awk '$2=="wifi"{print $1; exit}')
if [ -z "$device" ]; then
    echo "❌ 找不到 Wi-Fi 裝置"
    exit 1
fi

# 顯示主選單
while true; do
    echo ""
    echo "📶 Wi-Fi 管理工具"
    echo "-------------------------"
    echo "1️⃣  掃描並連接 Wi-Fi"
    echo "2️⃣  顯示目前連線狀態"
    echo "3️⃣  中斷目前連線"
    echo "4️⃣  離開"
    echo "-------------------------"
    read -p "➡ 請選擇操作 (1-4): " opt
    echo ""

    case $opt in
        1)
            echo "📡 掃描可用 Wi-Fi..."
            nmcli device wifi rescan >/dev/null 2>&1
            sleep 2

            wifi_list=$(nmcli -t -f SSID,SECURITY,SIGNAL device wifi list | awk -F: '!seen[$1]++ && $1 != ""')
            IFS=$'\n' read -rd '' -a wifi_array <<<"$wifi_list"

            if [ ${#wifi_array[@]} -eq 0 ]; then
                echo "❌ 沒有找到任何 Wi-Fi"
                continue
            fi

            echo "🔽 可用 Wi-Fi 列表："
            for i in "${!wifi_array[@]}"; do
                ssid=$(echo "${wifi_array[$i]}" | cut -d: -f1)
                security=$(echo "${wifi_array[$i]}" | cut -d: -f2)
                signal=$(echo "${wifi_array[$i]}" | cut -d: -f3)
                printf "  [%d] %s (🔐%s, 📶%s)\n" "$((i+1))" "$ssid" "$security" "$signal"
            done

            read -p "➡ 請選擇 Wi-Fi 編號: " choice
            ssid=$(echo "${wifi_array[$((choice-1))]}" | cut -d: -f1)

            read -s -p "🔑 請輸入 Wi-Fi 密碼: " password
            echo ""

            # 刪除已存在設定
            if nmcli connection show | grep -q "^$ssid"; then
                echo "🧹 移除舊連線設定..."
                nmcli connection delete id "$ssid" >/dev/null 2>&1
            fi

            echo "🔧 建立連線設定..."
            nmcli connection add type wifi ifname "$device" con-name "$ssid" ssid "$ssid" \
                && nmcli connection modify "$ssid" wifi-sec.key-mgmt wpa-psk \
                && nmcli connection modify "$ssid" wifi-sec.psk "$password"

            echo "🚀 嘗試連線中..."
            nmcli connection up "$ssid"

            echo "✅ 完成。"
            ;;
        2)
            current=$(nmcli -t -f NAME,DEVICE connection show --active | grep "$device" | cut -d: -f1)
            if [ -n "$current" ]; then
                ip=$(nmcli -f IP4.ADDRESS device show "$device" | grep IP4.ADDRESS | awk '{print $2}')
                echo "🌐 已連線到：$current"
                echo "📡 IP 位址：$ip"
            else
                echo "⚠️ 目前沒有 Wi-Fi 連線"
            fi
            ;;
        3)
            current=$(nmcli -t -f NAME,DEVICE connection show --active | grep "$device" | cut -d: -f1)
            if [ -n "$current" ]; then
                echo "🔌 中斷連線：$current"
                nmcli connection down "$current"
                echo "✅ 已中斷"
            else
                echo "⚠️ 沒有連線可中斷"
            fi
            ;;
        4)
            echo "👋 再見！"
            exit 0
            ;;
        *)
            echo "❌ 無效選項，請輸入 1-4"
            ;;
    esac
done
