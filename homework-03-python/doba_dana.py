#odredjivanje doba dana
#sati = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]

for s in range(24):
    if s >= 22 or s < 6:
        print('noć')
    elif s >= 6 and s < 12:
        print('jutro')
    elif s >= 12 and s < 18:
        print('popodne')
    #elif s >= 18 and s < 22:
    else:
        print('veče')