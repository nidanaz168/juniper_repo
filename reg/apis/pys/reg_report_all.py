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
import argparse




def task(data):
    # if data[1]=="":
    #     data[1]=data[2]
    command='/homes/rod/public_html/Regression/report/report.pl '+ data[0] +" "+data[1]+ " "+data[2] +" "+data[3]
    # print(command)
    p = Popen(command,stdout=PIPE,stderr=PIPE,shell=True)
    (output, err) = p.communicate()
    datas= output.decode("utf-8")
    # print(datas)
    # return datas


class Regression_DatabaseConnection():
    def __init__(self):
        try:
            self.connection = psycopg2.connect("dbname='regression' user='postgres' host='eabu-systest-db' password='postgres' port='5432'")
            self.connection.autocommit = True
            self.cursor = self.connection.cursor()
            # print("Successfully connected to database")
        except:
            # print("Cannot connect to database")
            pass

    def fetching_dr_id_record(self,releases,function):
        try:
            if function =="":
                releases_command = "select drnames,plannedrelease,releasename,function from regressionreport where releasename in (select release from releases where active='yes' and release in ({})) and releasename!='';".format(releases)
                # print("mani")
            else:
                releases_command = "select drnames,plannedrelease,releasename,function from regressionreport where function in({}) and releasename in (select release from releases where active='yes' and release in ({})) and releasename!='';".format(function,releases)

            # print(releases_command)
            self.cursor.execute(releases_command)
            fetch_datas = self.cursor.fetchall()
            jobs=[]
            for dr_id in fetch_datas:
                thread = threading.Thread(target=task, args=(dr_id,))
                jobs.append(thread)
            for a in jobs:
                a.start()
            for a in jobs:
                a.join()
            dic["status"]=1
            dic["message"]="Success"
            print(json.dumps(dic,indent=4))
        except Exception as a:
            # print(a)
            dic["status"]=0
            dic["message"]="UnSuccess. Please try again"
            # pass
            print(json.dumps(dic,indent=4))






if __name__ == '__main__':
    # releases=sys.argv[1:]
    args = argparse.ArgumentParser(description='Script to get all reg_report')
    args.add_argument('--rel', type=str, required=True)
    args.add_argument('--func', type=str, required=True)
    cargs = vars(args.parse_args())
    releases = cargs['rel']
    functions = cargs['func']
    dic={}
    # releases=releases[0].split(",")
    database_connection1 = Regression_DatabaseConnection()
    database_connection1.fetching_dr_id_record(releases,functions)











