import urllib.request
import json
import collections
import threading
import psycopg2
import time
import sys
start = time.time()
import traceback
#sys.path.append('/homes/pattabir/TOOLS/PYTHON/site-packages/')
#Pass =0

#mani =0
def tree():
     return collections.defaultdict(tree)
#tree = lambda: collections.defaultdict(tree)

dic = tree()
script_dic=tree()



class DatabaseConnection:
    def __init__(self):
        try:
            self.connection = psycopg2.connect("dbname='systest_live' user='readonly' host='ttpgdb.juniper.net' password='readonly' port='5432'")
            self.connection.autocommit = True
            self.cursor = self.connection.cursor()
            #print("Sucessfully connected to datase")
        except:
            pass
            #print("Cannot connect to datase")

    def display_record(self,id):
        try:
            display_command = "select DISTINCT result_id from er_regression_result where merge_result_id=0 and parent_result_id='"+str(id)+"';"
            #print(display_command)
            self.cursor.execute(display_command)
            datas = self.cursor.fetchall()
            drid='result_id='+str(id)
            for data in datas:
                drid=drid+' or result_id='+str(data[0])
            fail_command="select test_exec_id from er_debug_exec where ("+drid+");"
            pass_command="select test_exec_id from er_reg_pass_exec where ("+drid+");"
            self.cursor.execute(fail_command)
            Total_Fail=self.cursor.fetchall()
            self.cursor.execute(pass_command)
            Total_PASS=self.cursor.fetchall()
            #print(len(Total_Fail),Total_Fail)
            #print(len(Total_PASS),Total_PASS)
            #exit()
            return Total_Fail,Total_PASS

        except Exception as err:
            #print(err)
            pass


def fusionfetch(execution_id):
            #print("Hi")
            url="http://inception.juniper.net/fusion/v2/core/get_script_exec_results?ltr=2000&script_exec_id="+str(execution_id)
            response = urllib.request.urlopen(url)
            content = response.read()
            dt = json.loads(content.decode("utf8"))
            domain = dt['results'][0]['domain_name']
            pro_id=dt['results'][0]['script_profile_id']
            profile = dt['results'][0]['script_profile_name']
            #print(dt['results'][0]['exec_result'],pro_id)
            #print("Hi")
            if dt['results'][0]['exec_result'] == 'PASS' or dt['results'][0]['exec_result'] == 'CORE_PASS' or dt['results'][0]['exec_result'] == 'TC_RERUN_PASS':
                dic[domain][pro_id]['pass']=1
                dic[domain][pro_id]['fail'] = 0
            else:
                if (dic[domain][pro_id]['pass']==1):
                    pass
                else:
                    dic[domain][pro_id]['fail'] = 1
                    dic[domain][pro_id]['pass'] = 0

            if dt['results'][0]['exec_result'] == 'PASS' or dt['results'][0]['exec_result'] == 'CORE_PASS' or dt['results'][0]['exec_result'] == 'TC_RERUN_PASS':
                    script_dic[domain][profile] = 'PASS'
            else:
                if script_dic[domain][profile] =='PASS':
                    pass
                else:
                    script_dic[domain][profile] = dt['results'][0]['exec_result']






def batch(a, b):
    jobs = []
    for row in range(a, b):
        execution_id=output[row]
        thread = threading.Thread(target=fusionfetch, args=(execution_id,))
        jobs.append(thread)
    for a in jobs:
        a.start()
    for a in jobs:
        a.join()





if __name__ == '__main__':
    id=sys.argv[1]
    #id = '186860'
    #id = '192024'
    id=str(id)
    database_connection = DatabaseConnection()
    #database_connection.display_record(id)
    Totl_Fail,Total_Pass=database_connection.display_record(id)
    Total = len(Totl_Fail)+len(Total_Pass)
    output=[]
    dictnary = {}
    dictnary['pass'] = 0

    for execution in Total_Pass:
        output.append(execution[0])

    for execution in Totl_Fail:
        output.append(execution[0])

    divide = len(output)//50
    divide = divide*50
    reminder = len(output)%50
    for index in range(0, divide, 50):
        batch(index, (index + 50))
    if reminder > 0:
        batch(divide, len(output))

    for domain in dic.keys():
        for proid in dic[domain].keys():
            if 'pass' in dic[domain][proid].keys():
                pass
            else:
                dic[domain][proid]['pass']=0
            if 'fail' in dic[domain][proid].keys():
                pass
            else:
                 dic[domain][proid]['fail']=0
    Pass_count=0
    Fail_count=0
    Total_Pass_count=0
    Total_Fail_count=0
    #print(json.dumps(dic, indent=4))
    buffer = "<div id='123' style='float:left;width:500px;'><table id='myTable' width='100%' class='mission' border=1><thead><tr><th>Domain Name</th><th>Total Test</th><th>First Run Pass </th><th>% First Run Pass</th></tr><tbody>"
    for domain in dic.keys():
        if domain !="":
            for proid in dic[domain].keys():
                Pass_count+=dic[domain][proid]["pass"]
                Fail_count+=dic[domain][proid]["fail"]
            Total_Test=Fail_count + Pass_count
            percentage = str((Pass_count / (Fail_count + Pass_count)) * 100)
            buffer += "<tr><td><a href='javascript:showscripts('"+str(domain)+"');' >"+str(domain)+"</a></td><td>"+str(Total_Test)+"</td><td>"+str(Pass_count)+"</td><td>"+(str(percentage[:5])+"%")+"</td></tr>"
            Total_Pass_count+=Pass_count
            Total_Fail_count += Fail_count
            Pass_count = 0
            Fail_count = 0
    Total=Total_Fail_count + Total_Pass_count
    RPR=str(Total_Pass_count / (Total_Fail_count + Total_Pass_count) * 100)
    buffer += "<tr><td>Total</td><td>"+str(Total)+"</td><td>"+str(Total_Pass_count)+"</td><td>"+(str(RPR[:5])+"%")+"</td></tr></tbody></table></div>"

    Mainbuff=""
    #a=1

    for DOMAIN in script_dic.keys():
        dombuff = "<div id='"+DOMAIN+"',class='domain',style='display:none;float:left;margin-left:50px';><table class='mission' id='myTable-"+DOMAIN+"'><thead><tr><th>Domain</th><th>Profile Name</th><th>exitcode</th></tr></thead><tbody>"
        for Profile in script_dic[DOMAIN].keys():
            dombuff+="<tr><td>"+str(DOMAIN)+"</td><td>"+str(Profile)+"</td><td>"+str(script_dic[DOMAIN][Profile])+"</td></tr>"
        dombuff+="</tbody></table></div>"
        Mainbuff+=dombuff
        #a+=1
    print(buffer)
    print(Mainbuff)

    #print("Elapsed Time: %s" % (time.time() - start))
