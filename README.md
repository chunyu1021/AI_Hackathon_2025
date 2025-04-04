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

## ICAM 取像教學

1. 在 ICAM 網頁工具的首頁開新專案 (New Project)。

   ![image](https://github.com/user-attachments/assets/3a70b8d9-5d21-47ef-8fcb-7c6add6c8ec8)
   
2. 在專案設定畫面中填入專案名稱 (Project Name)、專案簡述 (Description)、選擇解析度 (Resolution)、像素格式 (Pixel Format)、啟動取像模式 (Trigger Mode)。設定完成後點擊「下一步」(Next)、並點擊「播放」(Play) 開始取像。

   ![image](https://github.com/user-attachments/assets/2cbdfbaa-b139-4e78-872b-3211d4f5f90e)
   
3. 取像過程中可利用影像預覽畫面下方的「儲存」(Save) 功能保存影像，但這項功能只有在「連續取像模式」(Continuous Mode) 能作用，且影像會被存入：`/opt/advantech/web/temp_-
folder/project/{projectName}/images`。

   ![image](https://github.com/user-attachments/assets/4ff49325-d3bb-4f8f-acc7-1efc87ba0357)

4. 影像預覽畫面右側的區域可以進行多種相機設定。另外，ICAM 也提供了 Python API 功能，讓使用者除了透過網頁工具進行設定，也能使用程式化的方式控制相機。API 使用方法與測試，請在網址列輸入：`http://<ICAM IP>/apidocs`

## ICAM 專案管理

按照上述步驟將 ICAM 設定完成後，專案就會出現在網頁工具的首頁。首頁提供基本的專案管理功能：

- Auto-run：啟用 Auto-run 將選定的專案設定自動啟動，只要 ICAM 開機時就會自動套用專案設定。

   ![image](https://github.com/user-attachments/assets/0697f092-9edb-488e-b6f6-077be534e138)

- 匯出專案 (Export)：將選定的專案匯出後，就能將設定檔下載保存並分享給其他 ICAM。

   ![image](https://github.com/user-attachments/assets/bcebca8d-ada9-4aac-bd97-583dd0eaca10)

- 匯入檔案 (Import)：將設定檔匯入網頁工具。

   ![image](https://github.com/user-attachments/assets/6ceae0e7-6d12-4edf-8c19-a3c38b14b690)

## 參考資料

- [User Manual of ICAM-540](https://downloadt.advantech.com/download/downloadsr.aspx?File_Id=1-2NA6ODY) (ICAM-540 使用手冊)
- [Programming Guide of ICAM-540](https://downloadt.advantech.com/download/downloadsr.aspx?File_Id=1-2NA6ODY) (ICAM-540 程式開發指南)
- [Getting Started Guide for AWS IoT_ICAM-540](https://downloadt.advantech.com/download/downloadsr.aspx?File_Id=1-2NTB7BO) (AWS IoT Greengrass 與 ICAM-540 協作指南)
