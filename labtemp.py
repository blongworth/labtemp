# netcat implementation


import socket
import errno
import sqlite3
from time import sleep, time
import csv


host = 'thdcfams'
db = '/home/brett/Projects/labtemp/labtemp.db'
ltfile = '/home/brett/labtemp'


def netcat(hostname, port, content):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((hostname, port))
    s.sendall(content)
    s.shutdown(socket.SHUT_WR)
    try:
        while 1:
            data = s.recv(1024)
            if data == "":
                break
            return repr(data)
    except socket.error as e:
        if e.errno != errno.ECONNRESET:
            raise
        pass
    s.close()


def readiServer(hostname):
    """Get temperature and humidity from hostname

    return list"""
    
    temp = netcat(hostname, 2000, "*SRTF\r")
    temp = temp[1:-1]
    sleep(0.5)
    rh = netcat(hostname, 2000, "*SRH\r")
    rh = rh[1:-1]
    return [temp, rh]

    
if __name__ == '__main__':

    # get the data
    ts = int(time())
    data = readiServer(host)

    # write to file
    f = open(ltfile, "a")
    try:
        w = csv.writer(f, quoting=csv.QUOTE_NONE)
        w.writerow( (ts, data[0], data[1]) )
    finally:
        f.close()

    # write to db
    try:
        conn = sqlite3.connect(db)
        c = conn.cursor()
        c.execute("INSERT INTO temp VALUES (?, ?, ?)", (ts, data[0], data[1]))
        conn.commit()

    except sqlite3.Error as e:
        print "Error %s:" % e.args[0]

    finally:
        if conn:
            conn.close()

