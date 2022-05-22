import os
import subprocess



#create main function
def main():
    #get hardware id
    hardwareID = subprocess.check_output('wmic csproduct get uuid').split('\n')[1].strip() 
    print(hardwareID)


main()