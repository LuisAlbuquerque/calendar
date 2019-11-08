import os, sys
#pandoc -t html5 --css style.css calendary.md -o calendary.pdf
ano = int(sys.argv[1])
semana = 1
def head_table(title,semana):
    print(f"|  semana {semana} |    {title}   |")
    print("| ------------- |:-------------:|")

def line(day):
    print(f"| {day}      |    |")

def table(weak):
    for dayM , dayW in weak:
        line("**"+str(dayM).strip(" ")+"**  " + str(dayW))

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
    table(line)
    #print("<hr/>")
    print("\n \\newpage \n")


MESES = ["Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"]
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

weak(month[0],prev_month + "/" + MESES[0],semana)
semana += 1

