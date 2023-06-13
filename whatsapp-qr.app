import streamlit as st
import urllib.request, urllib.error
import ftplib
path = "C:\\Users\\tapan\\OneDrive\\Desktop\\whatbot\\qrcodedecode\\"
import time
from datetime import datetime,timedelta
import json
import urllib.request
import requests
import qrcode
import zxingcpp
import numpy
import cv2
looper=0
updatetext1=0
message = ""
healthmessage="This is health message of QR coder/Decoder Whatsapp BOT. It is running fine and you are receiving this message every 60 minutes "
healthtime = int(time.time())
api="9VCT9UPA8KX4M99P2U4I"
param1= "apikey=9VCT9UPA8KX4M99P2U4I&type=IN&getnotpulledonly=1"
param2="apikey=9VCT9UPA8KX4M99P2U4I&type=IN&markaspulled=1&getnotpulledonly=1"
polltime=2
while looper==0:
    cn=0
    mime=""
    updatefile = open(path + "updateid.txt", 'r+')
    updatetext = updatefile.read()
    updatefile.close()
    time.sleep(polltime)
    lastupdate = int(updatetext)
    try:
      f = urllib.request.urlopen('http://panel.rapiwha.com/get_messages.php/?'+ param1)
      if str(f.getcode())=="200":
          pass
    except requests.exceptions.RequestException as e:
        continue

    data=json.load(f)
    b=data
    c=str(b)
    print(c)
    lenc=len(c)
    if lenc==2:
        print("No New message "+str(datetime.now().strftime("%H:%M:%S")))

    if lenc > 2:
      f = urllib.request.urlopen('http://panel.rapiwha.com/get_messages.php/?' + param2)
      print("Message received at: " + str(datetime.now().strftime("%H:%M:%S")))
      tempstr = c[0:lenc]
      while cn==0:
       idpos=tempstr.find("id")
       numberpos = tempstr.find("from")
       messagepos = tempstr.find("text")
       datepos = tempstr.find("creation_date")
       if numberpos==-1:
        break
       numbertext = tempstr[numberpos + 10:messagepos - 40]
       print(numbertext)
       messageid=tempstr[idpos+6:idpos+15]
       messagetext=tempstr[messagepos+8:datepos-4]
       datetext=tempstr[datepos+17:datepos+36]
       datetimestr=datetext
       datetext=datetime.strptime(datetimestr,'%Y-%m-%d %H:%M:%S')
       datetext=datetext+timedelta(hours=8.5)
       datetext=str(datetext)
       print(messageid)
       print(datetext)
       print(messagetext)
       print(messagetext[0:30])
       print(messagetext[0:13])
       updatetext1 = messageid
       print(updatetext1)
       userfile = open(path + "user.txt", 'r', encoding='utf-8', errors='ignore')
       usertext=userfile.read()
       userfile.close()
       find1=usertext.find(numbertext)
       if find1==-1:
        userfile = open(path + "user.txt", 'a' ,encoding='utf-8', errors='ignore')
        userfile.write(numbertext+","+datetext+"\n")
        userfile.close()
       finddot = messagetext.rfind(".")
       if finddot != -1:
           mime = messagetext[finddot:len(messagetext)]
           print("mime:" + mime)

       if len(messagetext)<2:
           phonejn = "+91" + numbertext
           message = "message cannot not be less than 1 character. Please send message in proper format "
           url = "https://panel.rapiwha.com/send_message.php"
           querystring = {"apikey": api, "number": phonejn, "text": message}
           response = requests.request("GET", url, params=querystring)
           #time.sleep(1)
           print(response.text)
           break
       if (mime == ".jpg" or mime == ".png" or mime == ".jpeg" or mime == ".bmp" or mime == ".webp") and messagetext[0:30]=="https://fs.magicrepository.com" :
           file_url = messagetext
           r = requests.get(file_url, stream=True)
           with open(path + "decoded" + mime, 'wb') as f:
               f.write(r.content)

           text = ""
           img = cv2.imread(path + "decoded" + mime)
           np_arr = numpy.array(img)

           result = zxingcpp.read_barcodes(np_arr)

           for r in result:
               text = r.text.encode(encoding='UTF-8')
           if text != "":
               print(text)
               phonejn = "+91" + numbertext
               url = "https://panel.rapiwha.com/send_message.php"
               querystring = {"apikey": api, "number": phonejn, "text": text}
               response = requests.request("GET", url, params=querystring)
               time.sleep(0.5)
               print(response.text)
               message = ""
               break
           elif text == "":
               phonejn = "+91" + numbertext
               url = "https://panel.rapiwha.com/send_message.php"
               querystring = {"apikey": api, "number": phonejn, "text": "Sent image does not contain a QR Code. Please send a QR code imgae only "}
               response = requests.request("GET", url, params=querystring)
               time.sleep(0.5)
               print(response.text)
               message = ""
               break

       elif (mime != ".jpg" and mime != ".png" and mime != ".jpeg" and mime != ".bmp" and  mime != ".webp") and messagetext[0:13]=="https://fs.ma" :
           message = "sent file is not a image. It is " + mime + " file"
           phonejn = "+91" + numbertext
           url = "https://panel.rapiwha.com/send_message.php"
           querystring = {"apikey": api, "number": phonejn,
                          "text": message}
           response = requests.request("GET", url, params=querystring)
           time.sleep(0.5)
           print(response.text)
           message = ""
           break
       if len(messagetext) > 2800:
           message = "Input Text must me less that 2800 charcters. Your text is of " + str(
               len(messagetext)) + " characters"
           phonejn = "+91" + numbertext
           url = "https://panel.rapiwha.com/send_message.php"
           querystring = {"apikey": api, "number": phonejn,
                          "text": message}
           response = requests.request("GET", url, params=querystring)
           time.sleep(0.5)
           print(response.text)
           message = ""
           break
       img = qrcode.make(messagetext)
       img.save(path + "qrcode.jpg")
       filename = path+"qrcode.jpg"
       HOSTNAME = "ftp.tanushiart.com"
       USERNAME = "u164421427.tanushiart"
       PASSWORD = "upa86g@F"

       # Connect FTP Server
       ftp_server = ftplib.FTP(HOSTNAME, USERNAME, PASSWORD)
       # force UTF-8 encoding
       ftp_server.encoding = "utf-8"
       with open(filename, "rb") as file:
           # Command for Uploading the file "STOR filename"
           ftp_server.storbinary('STOR ' + numbertext+".jpg", file)

       ftp_server.quit()
       message="https://tanushiart.com/qr/"+numbertext+".jpg"
       phonejn = "+91" + numbertext
       url = "https://panel.rapiwha.com/send_message.php"
       querystring = {"apikey": api, "number": phonejn,
                      "text": message}
       response = requests.request("GET", url, params=querystring)
       time.sleep(0.5)
       print(response.text)
       message = ""
       break


      tempstr = tempstr[datepos + 65:lenc]
    if int(updatetext1)>=int(updatetext):
      updatefile = open(path + "updateid.txt", 'w')
      updatetext = int(updatetext1)+1
      updatefile.write(str(updatetext))
      updatefile.close()

    healthtime1 = int(time.time())
    print(healthtime1)
    if healthtime1 - healthtime > 100:
        phonejn = "+91" + "6398370244"
        url = "https://panel.rapiwha.com/send_message.php"
        querystring = {"apikey": api, "number": phonejn,
                       "text": healthmessage}
        response = requests.request("GET", url, params=querystring)
        #time.sleep(0.5)
        print(response.text)
        healthtime = healthtime1


    print("Offset ID in Text File updated succesfully")

