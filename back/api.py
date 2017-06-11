#!/usr/bin/env python
# -*- coding: utf-8 -*-


#!/usr/bin/python
from flask import Flask,jsonify,abort, make_response
from flask import request
import json
import MySQLdb

app = Flask(__name__)

# db = MySQLdb.connect("localhost", "root", "yourDbPassWord", "DBname")

db = MySQLdb.connect(host="150.165.85.32", user="hackfest", passwd="H@ckfest", db="sagres", port=22030)

@app.route('/empenhos/', methods=['GET'])
def get_empenhos():
	args = request.args.to_dict()

	curs = db.cursor()

	query = """
			select * from ( select  emp_pag.nu_Empenho, emp_pag.cd_UGestora, emp_pag.cd_UnidOrcamentaria, emp_pag.dt_Ano, emp_pag.cd_Credor, avg(emp_pag.diffPag) as mean_diffPag
                  from (select e.nu_Empenho, p.cd_UGestora, e.dt_Ano, e.cd_UnidOrcamentaria, e.cd_Credor, e.no_Credor,
                        datediff(p.dt_Pagamento,e.dt_Empenho) as diffPag               
                         from empenhos e, pagamentos p
                           where CAST(e.cd_Ugestora as CHAR(50)) like '%{cod_muncipio}'
                            and e.cd_funcao = {cd_funcao}
                             and p.nu_Empenho = e.nu_Empenho
                              and p.cd_UGestora = e.cd_UGestora
                               and p.dt_Ano = e.dt_Ano and
                                p.cd_UnidOrcamentaria = e.cd_UnidOrcamentaria
                        ) emp_pag
                group by emp_pag.nu_Empenho, emp_pag.cd_UGestora, emp_pag.cd_UnidOrcamentaria, emp_pag.dt_Ano, emp_pag.cd_Credor) emp_group_pag,
                
               
                ( select  emp_liq.nu_Empenho, emp_liq.cd_UGestora, emp_liq.cd_UnidOrcamentaria, emp_liq.dt_Ano, emp_liq.cd_Credor, avg(emp_liq.diffLiq) as mean_diffLiq
                  from (select e.nu_Empenho, p.cd_UGestora, e.dt_Ano, e.cd_UnidOrcamentaria, e.cd_Credor, e.no_Credor,
                        datediff(p.dt_Liquidacao,e.dt_Empenho) as diffLiq              
                         from empenhos e, liquidacao p
                           where CAST(e.cd_Ugestora as CHAR(50)) like '%{cod_muncipio}'
                            and e.cd_funcao = {cd_funcao}
                             and p.nu_Empenho = e.nu_Empenho
                              and p.cd_UGestora = e.cd_UGestora
                               and p.dt_Ano = e.dt_Ano and
                                    p.cd_UnidOrcamentaria = e.cd_UnidOrcamentaria
                        ) emp_liq
                group by emp_liq.nu_Empenho, emp_liq.cd_UGestora, emp_liq.cd_UnidOrcamentaria, emp_liq.dt_Ano, emp_liq.cd_Credor) emp_group_liq
                
               where emp_group_liq.nu_Empenho = emp_group_pag.nu_Empenho and
                          emp_group_liq.cd_UGestora = emp_group_pag.cd_UGestora and
                          emp_group_liq.dt_Ano = emp_group_pag.dt_Ano and
                          emp_group_liq.cd_UnidOrcamentaria = emp_group_pag.cd_UnidOrcamentaria and
                          emp_group_liq.cd_Credor = emp_group_pag.cd_Credor and
                          emp_group_liq.cd_Credor = emp_group_pag.cd_Credor
                      
              ;"
		""".format(cod_muncipio=args["codigo_municipio"], cd_funcao=args["codigo_funcao"])

	print query


# 	nu_Empenho: 0000106
#          cd_UGestora: 201050
#  cd_UnidOrcamentaria: 00801
#               dt_Ano: 2012
#            cd_Credor: 00578443001055
# avg(emp_pag.diffPag): 46.0000
#           nu_Empenho: 0000106
#          cd_UGestora: 201050
#  cd_UnidOrcamentaria: 00801
#               dt_Ano: 2012
#            cd_Credor: 00578443001055
# avg(emp_liq.diffLiq): 2.0000

	curs.execute(query)

	temp=""

	data_list=[]

	for row in curs.fetchall():
		data_dict = {}
		data_dict['nu_Empenho']=  str(row[0])
		data_dict['cd_UGestora']= 	str(row[1])
		data_dict['cd_UnidOrcamentaria']= 	str(row[2])
		data_dict['dt_Ano']= 	str(row[3])
		data_dict['cd_Credor']= 	str(row[4])
		data_dict['avg(emp_pag.diffPag)']= 	str(row[5])
		data_dict['nu_Empenho']= 	str(row[6])
		data_dict['cd_UGestora']= 	str(row[7])
		data_dict['cd_UnidOrcamentaria']= 	str(row[8])
		data_dict['dt_Ano']= 	str(row[9])
		data_dict['cd_Credor']= 	str(row[10])
		data_dict['avg(emp_liq.diffLiq)']= 	str(row[11])
		data_list.append(data_dict)
	return json.dumps(data_list)

if __name__ == "__main__":
    app.run()