# AWS 服務與 ICAM 應用範例

⚡ ICAM 預設的影像輸出位置為 /dev/video10，無論是程式開發或使用 AWS 服務指令，若要使用 ICAM 影像，請務必先使用 [ICAM 網頁工具](https://github.com/chunyu1021/AI_Hackathon_2025?tab=readme-ov-file#icam-%E5%8F%96%E5%83%8F%E6%95%99%E5%AD%B8)將 ICAM 影像播放，如下圖 (Camera Status: Playing)。一旦影像已在播放狀態，就可將網頁關閉，影像會持續在 /dev/video10 輸出。

⚠️ ***請務必要將 ICAM 置於播放模式，否則 /dev/video10 將取不出影像。*** 

另外有兩個主要因素會影響上傳頻寬：

1. Frame rate - 預設值為 30 fps，可視現場頻寬大小，往下調節。 
2. Resolution - 下圖範例為 1920x1080，可視現場頻寬大小，調節適當的 Resolution。Resolution 調整後大小，將對應到以下範例中的 gst-launch-1.0 指令後面帶入參數值。

![image](https://github.com/user-attachments/assets/157fefec-ad50-42fb-a9c3-6b90121041dc)

## 將 ICAM 影像串流上 AWS KVS

參考網址：https://github.com/awslabs/amazon-kinesis-video-streams-producer-sdk-cpp

1. 在 ICAM 的 terminal 中輸入並執行步驟一到六。

   ```sh
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
9. 在 Create a new video stream 頁面中，輸入串流名稱，其他設定皆使用預設值，點選右下 Create video stream。
10. 回到 ICAM `amazon-kinesis-video-streams-producer-sdk-cpp` 資料夾 (注意！不是第三步驟中的 `build` 資料夾)，執行指令：

    ```sh
    export GST_PLUGIN_PATH=`pwd`/build
    export LD_LIBRARY_PATH=`pwd`/open-source/local/lib
    ```
11. 將自己的 Amazon IAM 的 Access Key、Secret Key，和所在的 AWS 區域，以參數形式帶入。

    ```sh
    export AWS_ACCESS_KEY_ID=<Your Access Key>
    export AWS_SECRET_ACCESS_KEY=<Your Secret Key>
    export AWS_DEFAULT_REGION=<Your Region>
    ```

12. 將 ICAM 影像串流上 AWS KVS，注意要將下列指令中的 "stream-name" 改為第九步驟所設定的串流名稱。

    ```sh
    gst-launch-1.0 v4l2src do-timestamp=TRUE device=/dev/video10 ! videoconvert ! video/x-raw,format=I420,width=1920,height=1080,framerate=30/1 ! x264enc bframes=0 key-int-max=30 bitrate=500 tune=zerolatency ! h264parse ! video/x-h264,stream-format=avc,alignment=au,profile=baseline ! kvssink stream-name="<Your Stream Name>" storage-size=512 fragment-duration=2000
    ```

13. 成功將 ICAM 影像串流上 AWS KVS 後，可再使用 AWS Lambda 將 KVS 串流影像上傳到 Amazon s3。

## 在 ICAM 上進行物件偵測，結果上傳 Amazon s3

參考網址：https://github.com/dusty-nv/jetson-inference/blob/master/docs/building-repo-2.md

1. 在 ICAM 的 terminal 中輸入並執行步驟一到六。

   ```sh
   sudo apt-get update
   sudo apt-get install git cmake libpython3-dev python3-numpy
   git clone --recursive --depth=1 https://github.com/dusty-nv/jetson-inference
   cd jetson-inference
   mkdir build
   cd build
   cmake ../
   make -j$(nproc)
   sudo make install
   sudo ldconfig
   ```
   
2. 安裝必要的 Python 套件，如：boto3 等等。

   ```sh
   python -m pip install boto3
   ```
   
3. 將自己的 Amazon IAM 的 Access Key、Secret Key，和所在的 AWS 區域，以參數形式帶入。

    ```sh
    export AWS_ACCESS_KEY_ID=<Your Access Key>
    export AWS_SECRET_ACCESS_KEY=<Your Secret Key>
    export AWS_DEFAULT_REGION=<Your Region>
    ```

4. 進入到 https://console.aws.amazon.com/s3/
5. 點選左側欄 General purpose buckets，再點選右上 Create bucket。
6. 在 Create bucket  頁面中，輸入 Bucket 名稱，其他設定皆使用預設值，點選右下 Create bucket。
7. 可選擇在新創設的 Bucket 中，新增資料夾：進入到 Bucket 頁面，再點選右上 Create folder、輸入資料夾名稱、點選右下 Create folder。
8. 修改下列 Python 程式碼，將 `S3_BUCKET` 改為第六步驟所設定的 Bucket 名稱、`S3_FOLDER` 改為第七步驟的資料夾名稱、`S3_REGION` 改為 AWS 所在地區。

   ```python
   #!/usr/bin/env python3

   import cv2
   import jetson.inference
   import jetson.utils
   import numpy as np
   import time
   import boto3
   from botocore.exceptions import NoCredentialsError
   import os
   from datetime import datetime
   
   # AWS S3 Configuration - Set to your specific bucket
   S3_BUCKET = 'icam-kvs-images-demo'
   S3_FOLDER = 'images/'
   S3_REGION = 'us-west-2'  # Change this if your bucket is in a different region
   
   # Detection settings
   PERSON_CLASS_ID = 1  # In COCO dataset, person is class 1
   CONFIDENCE_THRESHOLD = 0.5
   COOLDOWN_SECONDS = 5  # Time between captures to avoid multiple uploads of the same person
   
   def resize_for_display(image, max_width=1280, max_height=720):
       """Resize image for display purposes while maintaining aspect ratio"""
       h, w = image.shape[:2]
       
       # Calculate the resize factor
       scale = min(max_width / w, max_height / h)
       
       # Only resize if the image is larger than the max dimensions
       if scale < 1:
           new_w, new_h = int(w * scale), int(h * scale)
           resized = cv2.resize(image, (new_w, new_h))
           return resized
       return image
   
   def upload_to_s3(local_file, s3_key):
       """Upload a file to the S3 bucket"""
       s3_client = boto3.client('s3', region_name=S3_REGION)
       try:
           s3_client.upload_file(local_file, S3_BUCKET, s3_key)
           print(f"Upload Successful: s3://{S3_BUCKET}/{s3_key}")
           return True
       except FileNotFoundError:
           print("The file was not found")
           return False
       except NoCredentialsError:
           print("Credentials not available")
           return False
       except Exception as e:
           print(f"Error uploading to S3: {str(e)}")
           return False
   
   def detect_objects():
       # Load the detection network
       net = jetson.inference.detectNet("ssd-mobilenet-v2", threshold=CONFIDENCE_THRESHOLD)
       
       # Open the camera using OpenCV with /dev/video10
       cap = cv2.VideoCapture(10)  # Use 10 for /dev/video10
       
       # Set camera properties if needed
       cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
       cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
       cap.set(cv2.CAP_PROP_FORMAT, -1)
       
       if not cap.isOpened():
           print("Error: Could not open video device /dev/video10")
           return
       
       last_upload_time = 0
       
       while cap.isOpened():
           # Capture frame from OpenCV
           ret, frame = cap.read()
           if not ret:
               print("Failed to capture image from /dev/video10")
               time.sleep(0.2)
               continue
               
           # Convert OpenCV BGR image to CUDA format for Jetson Inference
           frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
           cuda_img = jetson.utils.cudaFromNumpy(frame_rgb)
           
           # Perform detection
           detections = net.Detect(cuda_img)
           
           person_detected = False
           current_time = time.time()
           
           # Process and display detections
           for detection in detections:
               class_id = detection.ClassID
               confidence = detection.Confidence
               left = int(detection.Left)
               top = int(detection.Top)
               right = int(detection.Right)
               bottom = int(detection.Bottom)
               
               # Draw bounding box
               cv2.rectangle(frame, (left, top), (right, bottom), (0, 255, 0), 2)
               
               # Add class label and confidence
               class_name = net.GetClassDesc(class_id)
               label = f"{class_name}: {confidence:.2f}"
               cv2.putText(frame, label, (left, top - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
               
               # Check if a person is detected with sufficient confidence
               if class_id == PERSON_CLASS_ID and confidence >= CONFIDENCE_THRESHOLD:
                   person_detected = True
           
           # If a person is detected and cooldown period has passed, capture and upload
           if person_detected and (current_time - last_upload_time) > COOLDOWN_SECONDS:
               timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
               local_filename = f"person_detected_{timestamp}.jpg"
               s3_key = f"{S3_FOLDER}person_detected_{timestamp}.jpg"
               
               # Save the image locally
               cv2.imwrite(local_filename, frame)
               print(f"Person detected! Image saved as {local_filename}")
               
               # Upload to S3
               if upload_to_s3(local_filename, s3_key):
                   last_upload_time = current_time
                   print(f"Image uploaded to s3://{S3_BUCKET}/{s3_key}")
               
               # Optional: Delete local file after upload
               os.remove(local_filename)
               print(f"Local file {local_filename} deleted")
           
           # Resize frame for display (without affecting processing or saved image quality)
           display_frame = resize_for_display(frame, max_width=800, max_height=600)
           
           # Display the resized frame
           cv2.imshow("Object Detection", display_frame)
           
           # Handle key presses
           key = cv2.waitKey(1)
           if key == 27:  # ESC key
               break
           elif key == ord('s'):  # Press 's' to save image manually
               timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
               manual_filename = f"manual_capture_{timestamp}.jpg"
               s3_manual_key = f"{S3_FOLDER}manual_capture_{timestamp}.jpg"
               
               cv2.imwrite(manual_filename, frame)
               print(f"Manually saved image to {manual_filename}")
               
               # Upload manual capture to S3
               if upload_to_s3(manual_filename, s3_manual_key):
                   print(f"Manual capture uploaded to s3://{S3_BUCKET}/{s3_manual_key}")
               
               # Optional: Delete local file after upload
               os.remove(manual_filename)
               print(f"Local file {manual_filename} deleted")
       
       # Clean up
       cap.release()
       cv2.destroyAllWindows()
       print('end program')
   
   if __name__ == "__main__":
       detect_objects()
   ```
