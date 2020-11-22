import os, sys
#pandoc -t html5 --css style.css calendary.md -o calendary.pdf
ano = int(sys.argv[1])
semana = 1

FERIADOS = { (1,1) : "Dia de ano novo",
        (2,4) : "Sexta-Feira Santa",
        (4,4) : "Páscoa",
        (25,4) : "Dia da Liberdade",
        (1,5) : "Dia do Trabalhador",
        (10,6) : "Dia de Portugal",
        (15,8) : "Assunção de Nossa Senhora",
        (5,10) : "Implantação da República",
        (1,11) : "Dia de Todos os Santos",
        (1,12) : "Restauração da Independência",
        (8,12) : "Dia da Imaculada Conceição",
        (25,12) : "Natal"
   }

LUAS = { (6,1) : "🌘",
        (13,1) : "🌑",
        (20,1) : "🌒",
        (28,1) : "🌕",
        (4,2) : "🌘",
        (11,2) : "🌑",
        (19,2) :  "🌒",
        (27,2) :  "🌕",
        (6,3) :   "🌘",
        (13,3) :  "🌑",
        (21,3) :  "🌒",
        (28,3) :  "🌕",
        (4,4) :   "🌘",
        (12,4) :  "🌑",
        (20,4) :  "🌒",
        (27,4) :  "🌕",
        (3,5) :   "🌘",
        (11,5) :  "🌑",
        (19,5) :  "🌒",
        (26,5) :  "🌕",
        (2,6) :   "🌘",
        (10,6) :  "🌑",
        (18,6) :  "🌒",
        (24,6) :  "🌕",
        (1,7) :   "🌘",
        (10,7) :  "🌑",
        (17,7) :  "🌒",
        (24,7) :  "🌕",
        (31,7) :  "🌘",
        (8,8) :   "🌑",
        (15,8) :  "🌒",
        (22,8) :  "🌕",
        (30,8) :  "🌘",
        (7,9) :   "🌑",
        (13,9) :  "🌒",
        (21,9) :  "🌕",
        (29,9) :  "🌘",
        (6,10) :  "🌑",
        (13,10) : "🌒",
        (20,10) : "🌕",
        (28,10) : "🌘",
        (4,11) :  "🌑",
        (11,11) : "🌒",
        (19,11) : "🌑",
        (27,11) : "🌘",
        (4,12) :  "🌑",
        (11,12) : "🌒",
        (19,12) : "🌕",
        (27,12) : "🌘",
   }

def specialDay(day, month, year, dic):
    day = int(day)
    month = int(month)
    if (day,month) in dic:
        return dic[ (day, month) ]
    return ''

def feriados(day, month, year):
    return specialDay(day, month, year, FERIADOS)

def luas(day, month, year):
    return specialDay(day, month, year, LUAS)


def head_table(title,semana):
    if(len(title.split('-')) > 1):
        m1 = title.split('-')[0].replace(' ','')
        m1 = MESES_PT[[i for i,m in enumerate(MESES) if(m == m1)][0]]

        m2 = title.split('-')[1].replace(' ','') 
        m2 = MESES_PT[[i for i,m in enumerate(MESES) if(m == m2)][0]]
        title = m1 + ' - ' + m2
    else:
        title = MESES_PT[[i for i,m in enumerate(MESES) if(m == title)][0]] 

    print(f"|  semana {semana} |    {title}   |")
    print("| ------------- |:-------------:|")

def line(title, day, month, year):
    if(len(month.split('-')) > 1):
        month = month.split('-')[0] if (int(day) > 20) else month.split('-')[1]
    month = month.replace(' ','')
    month = [i for i,m in enumerate(MESES) if(m == month)][0] + 1

    print(f"| {title}      |  {luas(day, month, year)} {feriados(day, month, year)}      |")

def table(weak, month, year):
    for dayM , dayW in weak:
        line("**"+str(dayM).strip(" ")+"**  " + str(dayW), dayM, month, year)

def split_days(l):
    return [(l[0:2],"Domingo"),(l[3:5],"Segunda"),(l[5:8],"Terça"),(l[9:11],"Quarta"),(l[12:14],"Quinta"),(l[15:17],"Sexta"),(l[18:20],"Sábado")]

def concat(list):
    r = []
    for x in list:
        r += (x)
    return r

def subsets(l):
    return[l[0:7],l[7:14],l[14:21],l[21:28],l[28:]]

def weak(line,month,semana):
    head_table(month,semana)
    table(line, month, ano)
    #print("<hr/>")
    print("\n \\newpage \n")


MESES_PT = ["Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"]
MESES = ["January","February","March","April","May","June","July","August","September","October","November","December"]
CAL = {}
#ano = 2020
for mes in range(1,13):
    p = os.popen(f"cal { mes } { ano }").read()
    p = p.split("\n")
    title = p[0]
    key = (list( filter( lambda x: x!="",title.split(" ")) )[0] )
    dias_semana = list( filter (lambda x: x != "",p[1].split(" ") ) )
    lines = list(map(split_days,p[2:]))

    lines = (concat(lines))
    lines = list( filter ( lambda x: x[0] != "", lines ) )
    lines = list( filter ( lambda x: x[0] != " ", lines ) )
    lines = list( filter ( lambda x: x[0] != "  ", lines ) )
    lines = list( filter ( lambda x: x[0] != "   ", lines ) )
    CAL[ key ] = lines

part_of_weak = []
prev_month = ""
#print(CAL)
if(CAL[MESES[0]][0][1] != "segunda"):
    p = os.popen(f"cal { MESES[ -1 ] } { ano - 1 }").read()
    p = p.split("\n")
    title = p[0]
    key = (list( filter( lambda x: x!="",title.split(" ")) )[0] )
    dias_semana = list( filter (lambda x: x != "",p[1].split(" ") ) )
    lines = list(map(split_days,p[2:]))

    lines = (concat(lines))
    lines = list( filter ( lambda x: x[0] != "", lines ) )
    lines = list( filter ( lambda x: x[0] != " ", lines ) )
    lines = list( filter ( lambda x: x[0] != "  ", lines ) )
    lines = list( filter ( lambda x: x[0] != "   ", lines ) )
    #print("")
    #print("")
    #print("")
    #print("")
    #print(lines)
    #print("")
    #print("")
    #print("")
    #print("")
    #print(lines)
    indice = 0

    for day in range(1,len(lines)):
        if(lines[ -(day)][1]=="Segunda"):
            #print(lines[-(day)])
            indice = -day
            break
    part_of_weak = (lines[indice:])
    prev_month = MESES[-1]



semana = 1
for mes in MESES:
    if(part_of_weak == []):
        month = subsets(CAL[mes])
        weak(month[0],mes,semana)
        semana += 1
        weak(month[1],mes,semana)
        semana += 1
        weak(month[2],mes,semana)
        semana += 1
        weak(month[3],mes,semana)
        semana += 1
        
        if(len(month[4])==7):
            weak(month[4],mes,semana)
            semana += 1

        elif(len(month[4])>7):
            weak(month[4][0:7],mes,semana)
            semana += 1
            part_of_weak = month[4][7:]
            prev_month = mes

        else:
            part_of_weak = month[4]
            prev_month = mes
    else:
        month = subsets(part_of_weak + CAL[mes])
        part_of_weak = []
        weak(month[0],prev_month + " - " + mes,semana)
        semana += 1
        weak(month[1],mes,semana)
        semana += 1
        weak(month[2],mes,semana)
        semana += 1
        weak(month[3],mes,semana)
        semana += 1

        if(len(month[4])==7):
            weak(month[4],mes,semana)
            semana += 1

        elif(len(month[4])>7):
            weak(month[4][0:7],mes,semana)
            semana += 1
            part_of_weak = month[4][7:]
            prev_month = mes

        else:
            part_of_weak = month[4]
            prev_month = mes


p = os.popen(f"cal { MESES[ 0 ] } { ano + 1 }").read()
p = p.split("\n")
title = p[0]
key = (list( filter( lambda x: x!="",title.split(" ")) )[0] )
dias_semana = list( filter (lambda x: x != "",p[1].split(" ") ) )
lines = list(map(split_days,p[2:]))

lines = (concat(lines))
lines = list( filter ( lambda x: x[0] != "", lines ) )
lines = list( filter ( lambda x: x[0] != " ", lines ) )
lines = list( filter ( lambda x: x[0] != "  ", lines ) )
lines = list( filter ( lambda x: x[0] != "   ", lines ) )
#print(lines)

month = subsets(part_of_weak + lines)

weak(month[0],prev_month + " - " + MESES[0],semana)
semana += 1

