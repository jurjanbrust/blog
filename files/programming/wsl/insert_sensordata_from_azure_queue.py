from azure.storage.queue import (
        QueueClient,
        TextBase64EncodePolicy,
        TextBase64DecodePolicy
)

import os, uuid, time, json
import mysql.connector
from datetime import datetime

connect_str = "DefaultEndpointsProtocol=https;AccountName=replace;AccountKey=replacewithyours;EndpointSuffix=core.windows.net"
queue_name = "name of queue"

mySql_dbName = "sensordata"
mySql_tableName = "temperature"

queue_client = QueueClient.from_connection_string(conn_str=connect_str, queue_name=queue_name, message_decode_policy=TextBase64DecodePolicy())
messages = queue_client.receive_messages(messages_per_page=5)

db = mysql.connector.connect(
  host="db",
  user="root",
  passwd="example",
  database=mySql_dbName
)
cursor = db.cursor()

def processMessage():
    message_json = json.loads(message.content)
    payload_raw = message_json["payload_raw"]
    payload_bytes = bytes(payload_raw, 'ascii')
    sensor_counter = payload_bytes[0] + 256 * payload_bytes[1]
    sensor_temperature = payload_bytes[2] + (payload_bytes[3] / 100)
    sensor_time = message_json["metadata"]["time"][0: 19]
    sensor_latitude = message_json["metadata"]["latitude"]
    sensor_longitude = message_json["metadata"]["longitude"]
    sensor_rssi = message_json["metadata"]["gateways"][0]["rssi"]
    sensor_dev_id = message_json["dev_id"]
    sensor_app_id = message_json["app_id"]
    sensor_hardware_serial = message_json["hardware_serial"]

    print("counter: " + str(sensor_counter) + " temp: " + str(sensor_temperature))
    sql = "INSERT INTO " + mySql_tableName + " (counter, temperature, time, latitude, longitude, rssi, dev_id, app_id, hardware_serial) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)"
    val = (sensor_counter, sensor_temperature, sensor_time, sensor_latitude, sensor_longitude, sensor_rssi, sensor_dev_id, sensor_app_id, sensor_hardware_serial)
    try:
      cursor.execute(sql, val)
      db.commit()
    except Exception as ex:
      print(ex)

for message in messages:
    processMessage()
    queue_client.delete_message(message.id, message.pop_receipt)
    time.sleep(0.1)

print("All Done")

