'''
1.Kreirati klasu BankAccount koja predstavlja bankovni račun.
Klasa treba da ima sledeće atribute:
owner – ime vlasnika računa;
balance – trenutno stanje na računu.'''

class BankAccount:
    def __init__(self, owner, balance):
        self.owner = owner
        self.balance = balance

    def deposit(self, amount: float): #uvećava stanje na računu za zadati iznos
        if amount > 0:
            self.balance = self.balance + amount
        return self
    
    def withdraw(self, amount: float): #umanjuje stanje na računu za zadati iznos
        if amount > 0 and self.balance >= amount:
            self.balance = self.balance - amount
        return self
    
    def display_balance(self):
        print(f'Stanje na računu: {self.balance}')




account = BankAccount("Ana", 10000)
print(account.balance)

account.deposit(5000).withdraw(2000).deposit(1000)
print(account.balance)

account.display_balance()

'''
2. Kreirati klasu UserProfile koja predstavlja profil korisnika.
Klasa treba da ima sledeće atribute:
username – korisničko ime;
email – imejl adresa;
city – grad;
active – informacija o tome da li je profil aktivan.
Prilikom kreiranja objekta, profil treba da bude aktivan.
'''

class UserProfile:

    def __init__(self, username, email, city):
        self.username = username
        self.email = email
        self.city = city
        self.active = True
    
    def change_email(self, email: str): #menja email adresu
        self.email = email
        return self
    
    def change_city(self, city: str): #menja grad
        self.city = city
        return self
    
    def deactivate(self): # deaktivira profil i vraća objekat
        self.active = False
        return self
    
    def activate(self): # aktivira profil i vraća objekat
        self.active = True
        return self
    
    def display_info(self): #ispisuje sve info o korisniku
        print(f'{self.username} {self.email} {self.city}')


user = UserProfile("ana123", "ana@gmail.com", "Nis")
print(user.username)

user.change_email('ana@yahoo.com').change_city('Beograd').deactivate()
print(user.active)

user.display_info()

'''
3.Kreirati klasu Product koja predstavlja proizvod u prodavnici.
Klasa treba da ima sledeće atribute:
name – naziv proizvoda;
price – cena proizvoda;
quantity – količina proizvoda na stanju.
'''

class Product:

    def __init__(self, name, price, quantity):
        self.name = name
        self.price = price
        self.quantity = quantity

    def change_price(self, new_price: float):  #menja cenu proizvoda
        if new_price > 0:
            self.price = new_price
        return self
    
    def add_stock(self, amount: int): #povećava količinu
        if amount > 0 :
            self.quantity = self.quantity + amount
        return self
    
    def sell(self, amount: int): #umanjuje količinu
        if amount > 0 and self.quantity >= amount:
            self.quantity = self.quantity - amount
        return self
    
    def display_info(self): #prikaz
        print(f'Informacije o proizvodu {self.name} {self.price} {self.quantity}')


product = Product('Laptop', 80000, 10)
print(product.name)

product.change_price(75000).sell(2).add_stock(5).sell(3)
print(product.quantity)

product.display_info()
