# 4/10 研華科技賽前工作坊

歡迎大家參加 2025 AWS x Advantech AI 黑客松 🚀

## 使用材料

- ICAM-540 (S-mount) * 1
- Power cable with M12 connector * 1
- Network adapter * 1
- Ethernet cable * 1

## ICAM-540 簡介

研華 ICAM-540 系列是一款先進的工業 AI 相機，具有多段變焦鏡頭、LED 照明、SONY 4K 工業級影像感測器、和 NVIDIA Orin NX 模組。其可變焦鏡頭和一體化的 LED 照明簡化了安裝和維護流程。

ICAM-540 系列包含了基於 Python 的 CAMNavi SDK 和 NVIDIA DeepStream SDK，簡化了從雲端到邊緣的視覺 AI 解決方案的開發和部署。CAMNavi SDK 專為影像獲取和 AI 演算法而優化，而網頁設定工具則提供圖形化的介面，便於相機設置和網路配置，進一步降低了設定複雜性。

產品特色：

- 8MP @30FPS，SONY 工業級感測器 (Full size: 3840(H) x 2160(V))
- S-mount 可變焦鏡頭或 C-mount 鏡頭
- 搭載 NVIDIA Jetson Orin NX 8GB
- 多種 LED 照明模式 (8 顆光源)
- 支援多種軟體 NVIDIA DeepStream、QV4L2 和 VLC 工具

## ICAM-540 線材安裝

本次工作坊需要參賽者連接電源、網路線：

- 電源連接 ICAM 接頭處上方有一向內凸起，用這凸起處對準 ICAM 上相對應的接口、插入接口後將接頭旋緊。接頭未旋緊前，勿通電。
- 網路線連接頭在左下位置也有一不規則形狀用以對準 ICAM 接口，將連接頭插入接扣後旋緊接頭。

![image](https://github.com/user-attachments/assets/fec24519-f8bf-4543-b9ec-42a1f9fe3801)

成功接上電源和連上網路後，電源指示燈顯示「綠色」；網路狀態指示燈顯示「橘色」。

![image](https://github.com/user-attachments/assets/2af6e526-4a6d-4264-8b9b-a9df6e3476ce)

## 啟動 ICAM 相機服務 (Web Utility)

ICAM 相機服務為可運行於瀏覽器上的網頁服務，使用者透過使用網頁介面操作 ICAM 的取像和網路設定。以下介紹在 ICAM 和遠端進入網頁介面的方式：

- 由 ICAM 上瀏覽器進入：在瀏覽器的網址列中輸入 `localhost:5000`，即可連接網頁。
- 由遠端 (另一台裝置) 進入：
	- 區域網路連線：將裝置和 ICAM 連接於同一區域網路內，在裝置的瀏覽器網址列輸入 `<ICAM IP>:5000`，即可連接網頁。
	- 網路線對接裝置和 ICAM：將網路線對接裝置與 ICAM，在裝置上設定網路連線 (TCP/IPv4)，IP 設定為 `192.168.0.X` (X 可為 0-255 任一數字，但勿與已存在 IP 位置衝突)、子網路遮罩 (subnet mask) 設定為 `255.255.255.0`。在裝置的瀏覽器網址列輸入 `192.168.0.100:5000`，即可連接網頁。

相機網頁服務如下圖所示：

![image](https://github.com/user-attachments/assets/a3a01b56-3f0c-44c2-8027-202b4fe93f6d)


