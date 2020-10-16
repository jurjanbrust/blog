import mysql.connector

mySql_dbName = "sensordata"
mySql_tableName = "temperature"
mySql_password = "example"
mySql_droptable = False

db = mysql.connector.connect(
  host="db",
  user="root",
  passwd=mySql_password,
)

cursor = db.cursor()
try:
    cursor.execute("CREATE DATABASE IF NOT EXISTS " + mySql_dbName)
except Exception as ex:
    print(ex)

db = mysql.connector.connect(
  host="db",
  user="root",
  passwd=mySql_password,
  database=mySql_dbName
)
cursor = db.cursor()

if(mySql_droptable):
    try:
        cursor.execute("DROP TABLE " + mySql_tableName)
        print("Deleted table" + mySql_tableName)
    except Exception as ex:
        print(ex)

try:
    cursor.execute("CREATE TABLE "+ mySql_tableName + " (id INT AUTO_INCREMENT PRIMARY KEY, counter INT, temperature INT, time TIMESTAMP, latitude FLOAT, longitude FLOAT, rssi FLOAT, dev_id VARCHAR(20), app_id VARCHAR(20), hardware_serial VARCHAR(20) )")
    print("Created table" + mySql_tableName)
except Exception as ex:
    print(ex)
