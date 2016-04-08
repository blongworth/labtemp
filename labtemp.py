# netcat implementation


import socket
import errno
import sqlite3
from time import sleep, time

host = 'thdcfams'
db = '/home/brett/Projects/labtemp/labtemp.db'


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


if __name__ == '__main__':

    ts = int(time())
    temp = netcat(host, 2000, "*SRTF\r")
    sleep(0.5)
    rh = netcat(host, 2000, "*SRH\r")

    try:
        conn = sqlite3.connect(db)
        c = conn.cursor()
        c.execute("INSERT INTO test VALUES (?, ?, ?)", (ts, temp, rh))
        conn.commit()

    except sqlite3.Error as e:
        print "Error %s:" % e.args[0]

    finally:
        if conn:
            conn.close()

