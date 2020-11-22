import os, sys
#from toolz import curry

class Infix:
    def __init__(self, function):
        self.function = function
    def __ror__(self, other):
        return Infix(lambda x, self=self, other=other: self.function(other, x))
    def __or__(self, other):
        return self.function(other)
    def __rlshift__(self, other):
        return Infix(lambda x, self=self, other=other: self.function(other, x))
    def __rshift__(self, other):
        return self.function(other)
    def __call__(self, value1, value2):
        return self.function(value1, value2)

def compose(*functions):
    return functools.reduce(lambda f, g: lambda x: f(g(x)), functions, lambda x: x)

last = lambda x : x[-1]
head = lambda x : x[0]
swap = lambda pair : (last(pair),head(pair))
succ = lambda x : x+1
comp = lambda f1,f2 : lambda x : f1(f2(x))
id = lambda x: x

#X = Infix(lambda f1: lambda f2 : lambda value: (f1(head(value)) ,f2(last(value))))
#res = (succ |X| succ)((1,2))
#print(res)
swap_succ_id = lambda pair : (last(pair),head(pair)+1)

numero_dourado = [(14,"March"),(3,"April"),(23,"March"),(11,"April"),(31,"March"),(18,"April"),(8,"April"),(28,"March"),(16,"April"),(5,"April"),(25,"March"),(13,"April"),(2,"April"),(22,"Mach"),(10,"April"),(30,"Mach"),(17,"April"),(7,"April"),(27,"Mach")]

MONTHS = ["January","February","March","April","May","June","July","August","September","October","November","December"]
Month_to_number = dict( map( swap_succ_id, enumerate(MONTHS) ) ) 
number_to_Month = dict( enumerate(MONTHS))
#print(Month_to_number)


def horas():
    res = [( 0,0 )]
    while(1):
        hora, minuto = last(res)
        if(int(minuto) < 59): res.append((hora ,str(int(minuto) + 1)))
        elif(int(hora) < 23): res.append((str(int(hora) + 1) , "00"))
        else: break
    return res

def concat(list):
    r = []
    for x in list:
        r += (x)
    return r

def split_days(l):
    return [(l[0:2],"Domingo"),(l[3:5],"Segunda"),(l[5:8],"Terça"),(l[9:11],"Quarta"),(l[12:14],"Quinta"),(l[15:17],"Sexta"),(l[18:20],"Sábado")]

def try_int(string):
    try:
        return int(string) 
    except:
        return int(os.popen("date | awk '{print $2}'").read())

def cal(mes,ano):
    p = os.popen(f"cal { mes } { ano }").read()

    p = p.split("\n")
    title = p[0]
    key = (list( filter( lambda x: x!="",title.split(" ")) )[0] )
    dias_semana = list( filter (lambda x: x != "",p[1].split(" ") ) )
    lines = list(map(split_days,p[2:]))
    #print(lines)
    lines = (concat(lines))
    lines = list( filter ( lambda x: x[0] != "", lines ) )
    lines = list( filter ( lambda x: x[0] != " ", lines ) )
    lines = list( filter ( lambda x: x[0] != "  ", lines ) )
    lines = list( filter ( lambda x: x[0] != "   ", lines ) )
    lines = list( map ( lambda x: (try_int(x[0]),x[1]), lines ) )
    return(lines)

def fim_de_semana(dia,mes,ano):
    return dict(cal(mes,ano))[dia] in ["Sábado", "Domingo"]

def week(dia,mes,ano):
    return dict(cal(mes,ano))[dia]

def last_day(month,year):
    return head( last( cal(month,year) ) )

def previus_day(day,month,year):
    """ 
    day: Int
    month: Int
    year: Int
    """
    if(day>1):          return (day-1,month,year)
    elif(month>1):      return (0,month-1,year)
    else:               return (0,0,year-1)

#def add_days(days_to_add,day,month,year):
#    return 


def next_day(day,month,year):
    """ 
    day: Int
    month: Int
    year: Int
    """
    if(day< last_day(month,year)):      return (day+1,month,year)
    elif(month<12):                     return (0,month+1,year)
    else:                               return (0,0,year+1)


def math_day(day,month,year,days, func):
    if(days == 0): return (day, month, year)
    (day, month, year) = func(day, month, year)
    return plus_day(day, month, year, days - 1)

def plus_day(day,month,year,days):
    return math_day(day, month, year, days, next_day)

def minus_day(day,month,year,days):
    return math_day(day, month, year, days, previus_day)


def proximo_aux(day,month,year,week_day,day_i):
    if(week(day,month,year) == week_day):   return (day,month)
    elif(day < last_day(month,year)):       return  proximo_aux(day+1,month,year,week_day,day_i)
    elif(month != 12 ):                     return  proximo_aux(1,month+1,year,week_day,day_i)
    else:                                   return  proximo_aux(1,1,year+1,week_day,day_i)



def proximo(day,month,year,week_day):
    #print(day,month,year,week_day)
    return proximo_aux(day,month,year,week_day,day)

#print(week(8,3,2020))

def pascoa(year):
    day , month = numero_dourado[ year % 19 ]
    return proximo(day, Month_to_number[ month ], year ,"Domingo")


def feriados(dia,mes,ano):
    pascoa_ = pascoa(ano)
    pascoa_ = (pascoa_[0], pascoa_[1], ano)

    # Carnaval (terça feira) é 47 dias antes da pascoa
    carnaval = minus_day(pascoa_[0],pascoa_[1], ano, 47)

    # Corpo de Deus (quinta feira) é 60 dias depois da pascoa
    corpo_deus = plus_day(pascoa_[0],pascoa_[1], ano, 50)

    # Sexta feira Santa (sexta feira) Sexta feira antes da pascoa
    #sexta_feira_santa = plus_day(pascoa_[0],pascoa_[1], ano, 50)

    # (1,"Janeiro") Dia de Ano novo
    ano_novo = (1,1,ano)
    # (25,"April") Dia da Liberdade
    dia_liverdade  = (25,4,ano)
    # (1,"Maio") Dia do Trabalhador
    dia_trabalhador = (1,5,ano)
    # (10,"Julho") Dia de Portugal
    dia_portugal = (10,7,ano)
    # (15,"Agosto") Assunção de Nossa Senhora
    assuncao_nossa_senhora = (15,8,ano)
    # (5,"Outubro") Implantação da República
    implementacao_republica = (5,10,ano)
    # (1,"Novembro") Dia de todos os Santos
    dia_todos_santos = (1,11,ano)
    # (1,"Dezembro") Restauração da Independência
    restauracao_independencia = (1,12,ano)
    # (8,"Dezembro") Dia da Imaculada Conceição
    imaculada_conceicao = (8,12,ano)
    # (25,"Dezembro") Natal
    natal = (25,12,ano)

    feriados_list = [pascoa_ , carnaval , corpo_deus, ano_novo , dia_liverdade, dia_trabalhador, dia_portugal, assuncao_nossa_senhora, implementacao_republica, dia_todos_santos , restauracao_independencia , imaculada_conceicao , natal ]
    #print(feriados_list)
    print((dia, mes, ano) in feriados_list)


#feriados(10,4,2020)
feriados(int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3]))
