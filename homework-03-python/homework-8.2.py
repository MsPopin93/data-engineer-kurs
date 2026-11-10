#16. Написати функцију count_lines(path: str) -> int која враћа број непразних редова у фајлу
#Input: 'data/raw/teams.csv'
#Output: 5

# otvorimo fajl i import datoteke
import csv

def count_lines(path: str) -> int:
    
    
    with open(path, 'r', encoding = 'utf-8') as f:
        lista = f.readlines()  #vraća sve redove kao listu
        
        brojac = 0
        for l in lista: #za svaki red u listi
            if l.strip(): #string bez \n
                brojac +=1
        return brojac
                


count_lines('/Workspace/Users/ivana.popin93@gmail.com/python/data/raw/teams.csv')

# 17. Написати функцију read_column(path: str, column: str) -> list која враћа све вредностиједне колоне CSV фајла
'''
Input: 'data/raw/teams.csv','city'
Output: ['Bela Palanka', 'Niš', 'Beograd, Rakovica', 'Kraljevo']
Ако колона не постоји, вратити празну листу []
'''
import csv

def read_column(path: str, column: str) -> list:

    with open(path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        
        if column not in reader.fieldnames: #lista imena kolona iz zaglavlja
            return []  #prazna lista ako ta kolona ne postoji
        else: 
            vrednost_kolone = []  #napravi praznu listu, u koju skupljamo vrednosti iz trazene kolone
            for jedan_red in reader:
                vrednost_kolone.append(jedan_red[column])
    return vrednost_kolone

read_column('/Workspace/Users/ivana.popin93@gmail.com/python/data/raw/teams.csv', 'city')

# 18. Написати функцију write_key_value(path: str, data: dict, headers: list) -> None која речник уписује у CSV фајл са две колоне
# Input: 'data/processed/summary.csv',{'rows': 10, 'valid': 6},['metric', 'value']
#Садржај фајла након позива:
    #metric,value
    # rows,10
    # valid,6

def write_key_value(path: str, data: dict, headers: list) -> None:

    with open(path, 'w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(headers)

        for key, value in data.items():
            writer.writerow([key, value])




write_key_value('/Workspace/Users/ivana.popin93@gmail.com/python/data/processed/summary.csv', {'rows': 10, 'valid': 6},['metric', 'value'])


with open('/Workspace/Users/ivana.popin93@gmail.com/python/data/processed/summary.csv', 'r', encoding='utf-8') as f:
    print(f.read())

# 19. Написати функцију get_header(path: str) -> list која враћа заглавље CSV фајла. Користити csv.reader и next()
#Input: 'data/raw/teams.csv'
#Output: ['team', 'city', 'points']

def get_header(path: str) -> list:

    with open(path, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        zaglavlje = next(reader)
    return zaglavlje

get_header('/Workspace/Users/ivana.popin93@gmail.com/python/data/raw/teams.csv')

# 20. Написати функцију read_rows(path: str) -> list која враћа све редове CSV фајла без заглавља, као листу листи.
#Користити csv.reader 
# Input: 'data/raw/teams.csv'
#Output: [['FK Jedinstvo', 'Bela Palanka', '34'], ['FK Radnički', 'Niš', '41'],['FK Rakovica', 'Beograd, Rakovica', '28'], ['FK Sloga', 'Kraljevo', '19']]

def read_rows(path: str) -> list:

    with open(path, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        next(reader) #preskace zaglavlje

        svi_redovi = []
        for red in reader:  #petlja prolazi kroz preostale redove
            svi_redovi.append(red)

    return svi_redovi

read_rows('/Workspace/Users/ivana.popin93@gmail.com/python/data/raw/teams.csv')

#21. Написати функцију total_points(path: str) -> int која враћа збир бодова свих тимова 
#Користити csv.DictReader
#Input: 'data/raw/teams.csv'
#Output: 122

import csv

def total_points(path: str) -> int:

    with open(path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)

        suma = 0 #van petlje da se ne bi resetovala u svakoj iteraciji

        for jedan_red in reader:
            suma = suma + int(jedan_red['points'])

    return suma

total_points('/Workspace/Users/ivana.popin93@gmail.com/python/data/raw/teams.csv')

# 22. Написати функцију write_rows(path: str, rows: list) -> None која листу листи уписује у CSV фајл
#Input: 'data/processed/people.csv', [['name', 'age'], ['Ana', 20], ['Marko', 22]]
# Садржај фајла након позива: 
# name,age
# Ana,20
# Marko,22

def write_rows(path: str, rows: list) -> None:

    with open(path, 'w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        writer.writerows(rows)


write_rows('/Workspace/Users/ivana.popin93@gmail.com/python/data/processed/people.csv', [['name', 'age'], ['Ana', 20], ['Marko', 22]])

with open('/Workspace/Users/ivana.popin93@gmail.com/python/data/processed/people.csv', 'r', encoding='utf-8') as f:
    print(f.read())

# 23. Написати функцију write_dicts(path: str, rows: list) -> None која листу речника уписује у CSV фајл.
# Користити csv.DictWriter; заглавља су кључеви првог речника
# Input: 'data/processed/people.csv', [{'name': 'Ana', 'age': 20}, {'name':'Marko', 'age': 22}]
# Садржај фајла након позива: 
# name,age
# Ana,20
# Marko,22
#csv.DictWriter(f, fieldnames=...) - upisuje rečnike, treba i .writeheader()

def write_dicts(path: str, rows: list) -> None:

    with open(path, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=rows[0].keys())

        writer.writeheader() #upisuje zaglavlje, uzima automatski nazive iz fieldnames
        writer.writerows(rows) #upisuje sve ostale redove
    
write_dicts('/Workspace/Users/ivana.popin93@gmail.com/python/data/processed/people.csv', [{'name': 'Ana', 'age': 20}, {'name':'Marko', 'age': 22}])

with open('/Workspace/Users/ivana.popin93@gmail.com/python/data/processed/people.csv', 'r', encoding='utf-8') as f:
    print(f.read())
