# ===================================
# ZADATAK 1
# ===================================
Ferenhajt vs Celzijus

def temperatura(c):
    return c * 1.80 + 32


f = temperatura(3)
print(f)

# ===================================
# ZADATAK 2
# ===================================
Ime dana u nedelji na osnovu broja dana u nedelji

dani_u_nedelji = ['ponedeljak', 'utorak', 'sreda', 'cetvrtak', 'petak', 'subota', 'nedelja']

def dani(broj):
    if broj in range(1, 8):
        return dani_u_nedelji[broj-1] #py liste indeksiraju od 0
    else:
        return 'Pogresan unos'
    
print(dani(7))
print(dani(1))
print(dani(10))


#print(list(calendar.day_name))
#-1 neophodan kada korisnik unosi brojeve 1-7, a Python pristupa elementima preko indeksa 0-6

# ===================================
# ZADATAK 3
# ===================================
#Najveći negativni element liste

#lista = [-5, -1, -10, 3, 7, 12]

def najveci_negativni(lista):
    rezultat = [] #def lokalno, kako bi se praznila svaki put pred pozivanje funkcije
    #kreiram novu listu od samo negativnih brojeva
    for l in lista:
        if l < 0:
            rezultat.append(l)
    #za slučaj da je lista prazna(false) ili ima samo pozitivnih brojeva        
    if rezultat: #True
        return max(rezultat)
    else: #false
        return 'Nema negativnih brojeva'


najveci_negativni([3, 7])

# ===================================
# ZADATAK 5
# ===================================
#Suma parnih brojevi date liste
#parni brojevi su oni brojevi koji su deljivi sa 2 bez ostatka


#lista = [-5, -1, -10, 3, 7, 12]

def parni_brojevi(broj):
    parna_lista = []
    for b in broj:
        if b % 2 == 0:
            parna_lista.append(b)
    return len(parna_lista)



parni_brojevi([3, 7, 12]) 

# ===================================
# ZADATAK 6
# ===================================
# Program koji računa sume elemenata liste celih brojeva koji su deljivi sa 2 odnosno sa 3
#lista brojeva delivih sa 2
#lista brojeva deljivih sa 3
# 2 if - jer npr 6 moze u obe kategorije

#listu = [2, 3, 4, 6, 7, 9]

def suma(deljenik):
    delilac2 = []
    delilac3 = []
    for d in deljenik:
        if d % 2 == 0: #deljivo sa 2
            delilac2.append(d)
        if d % 3 == 0: #deljivo sa 3
            delilac3.append(d)
    return sum(delilac2), sum(delilac3)
    
suma([2, 3, 4, 6, 7, 9])