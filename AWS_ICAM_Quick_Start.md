# AWS 服務與 ICAM 應用範例

⚡ ICAM 預設的影像輸出位置為 /dev/video10，無論是程式開發或使用 AWS 服務指令，若要使用 ICAM 影像，請務必先使用 [ICAM 網頁工具](https://github.com/chunyu1021/AI_Hackathon_2025?tab=readme-ov-file#icam-%E5%8F%96%E5%83%8F%E6%95%99%E5%AD%B8)將 ICAM 影像播放。一旦影像已在播放狀態，就可將網頁關閉，影像會持續在 /dev/video10 輸出。

## 將 ICAM 影像串流上 AWS KVS

參考網站：https://github.com/awslabs/amazon-kinesis-video-streams-producer-sdk-cpp

1. ```sh
   git clone https://github.com/awslabs/amazon-kinesis-video-streams-producer-sdk-cpp.git
   ```
3. ```sh
   mkdir -p amazon-kinesis-video-streams-producer-sdk-cpp/build
   cd amazon-kinesis-video-streams-producer-sdk-cpp/build
   ```
4. ```sh
   sudo apt-get install libssl-dev libcurl4-openssl-dev liblog4cplus-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base-apps gstreamer1.0-plugins-bad gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-tools
   ```
5. ```sh
   cmake -DBUILD_GSTREAMER_PLUGIN=TRUE ..
   ```
6. ```sh
   make
   ```
7. 進入到 https://console.aws.amazon.com/kinesisvideo/home
8. 點選左側欄 Video streams，再點選右上 Create video stream。
9. 在 Create a new video stream 頁面中，輸入串流名稱，其他設定皆使用預設值。
10. 回到 ICAM `amazon-kinesis-video-streams-producer-sdk-cpp` 資料夾 (注意！不是第三步驟中的 `build` 資料夾)，執行指令：

    ```sh
    export GST_PLUGIN_PATH=`pwd`/build
    export LD_LIBRARY_PATH=`pwd`/open-source/local/lib
    ```
12. 將自己的 Amazon IAM 的 Access Key、Secret Key，和所在的 AWS 區域，以參數形式帶入。

    ```sh
    export AWS_ACCESS_KEY_ID=<Your Access Key>
    export AWS_SECRET_ACCESS_KEY=<Your Secret Key>
    export AWS_DEFAULT_REGION=<Your Region>
    ```

13. 將 ICAM 影像串流上 AWS KVS，注意要將下列指令中的 "stream-name" 改為第九步驟所設定的串流名稱。

    ```sh
    gst-launch-1.0 v4l2src do-timestamp=TRUE device=/dev/video10 ! videoconvert ! video/x-raw,format=I420,width=1920,height=1080,framerate=30/1 ! x264enc bframes=0 key-int-max=30 bitrate=500 tune=zerolatency ! h264parse ! video/x-h264,stream-format=avc,alignment=au,profile=baseline ! kvssink stream-name="<Your Stream Name>" storage-size=512 fragment-duration=2000
    ```
