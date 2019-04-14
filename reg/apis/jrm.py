#import openpyxl
import urllib.request
import json
#from datetime import *
import psycopg2
import collections
import sys
import pymysql
import time
import threading
from subprocess import Popen,PIPE

class Psql_DatabaseConnection():
    def __init__(self):
        try:
            self.connection = psycopg2.connect("dbname='regression' user='postgres' host='eabu-systest-db' password='postgres' port='5432'")
            self.connection.autocommit = True
            self.cursor = self.connection.cursor()
            #print("Successfully connected to database")
        except:
            #print("Cannot connect to database")
            pass

    def fetching_dr_id_record(self):
        try:
            releases_command = "select releasename, function, debugend, scriptplanned, scriptexecuted, totaldebugcount+respindebugcount as total_debug, completeddebugcount+respincompleteddebug as completed_debug, tobedebugged+respinpendingdebug as pending_debug,  overallpassrate, openblockerprs,debugids from regressionreport where releasename in (select release from releases where active='yes') group by releasename, function, scriptplanned, scriptexecuted, total_debug, completed_debug, pending_debug, overallpassrate, openblockerprs, debugend ,debugids order by releasename,function"
            #print(releases_command)
            self.cursor.execute(releases_command)
            fetch_datas = self.cursor.fetchall()
            for data in fetch_datas:
            	print(data)
                # if dr_id[0] in team['data']:
                #     submission = database_connection2.fetching_record(dr_id[2])
                #     for data in submission:
                #         # submission, debugid, rel, fun
                #         a=data[0], data[1], dr_id[1], dr_id[0],sql_database_connection.created_by_launcher(data[0]),sub_release
                #         rel_lst.append(a)

        except Exception as a:
            #print(a)
            pass




if __name__ == '__main__':
	database_connection = Psql_DatabaseConnection()
	database_connection.fetching_dr_id_record()










