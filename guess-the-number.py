import random
import click
def init():
    l = random.randint(1, 10)
    #print(l)
    main(l)

def main(l):
    eingabe = 0
    del eingabe
    try:
        eingabe = int(input("Rate die Zahl "))
    except:
        print("Das ist keine Zahl")
        main(l)
    #print(eingabe)
    if l == eingabe:
        print("###################")
        print("# Richtig geraten #")
        print("###################")
        if click.confirm('Do you want to continue?', default=True):
            init()
        else:
            exit()
    else:
        print("Leider falsch :(")
        main(l)
init()


