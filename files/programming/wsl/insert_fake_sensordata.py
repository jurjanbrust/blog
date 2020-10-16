import os, uuid, time, json, random
import mysql.connector
from datetime import datetime

mySql_dbName = "sensordata"
mySql_tableName = "temperature"
nrOfMessages = 100

db = mysql.connector.connect(
  host="db",
  user="root",
  passwd="example",
  database=mySql_dbName
)
cursor = db.cursor()

def processMessage():
    sensor_counter = random.randrange(1,4000,1)
    sensor_temperature = random.randrange(30,40,1)
    sensor_time = datetime.today()
    sensor_latitude = "123.22"
    sensor_longitude = "334.22"
    sensor_rssi = random.randrange(-100,-0,1)
    sensor_dev_id = "223423434"
    sensor_app_id = "3322334"
    sensor_hardware_serial = "sensor1"

    print("counter: " + str(sensor_counter) + " temp: " + str(sensor_temperature))
    sql = "INSERT INTO " + mySql_tableName + " (counter, temperature, time, latitude, longitude, rssi, dev_id, app_id, hardware_serial) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)"
    val = (sensor_counter, sensor_temperature, sensor_time, sensor_latitude, sensor_longitude, sensor_rssi, sensor_dev_id, sensor_app_id, sensor_hardware_serial)
    try:
      cursor.execute(sql, val)
      db.commit()
    except Exception as ex:
      print(ex)

for item in range(0, nrOfMessages, 1):
    processMessage()
    time.sleep(1)

print("All Done")