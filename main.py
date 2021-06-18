#IDFK what I dit here

""" from time import sleep
import threading
import tkinter as tk
class Application(tk.Frame):
    def __init__(self, master=None):
        super().__init__(master)
        self.master = master
        self.pack()
        self.create_widgets()

    def create_widgets(self):
        self.th = threading.Thread(target=self.say_hi, args=1)
        self.hi_there = tk.Button(self)
        self.hi_there["text"] = "Yeee"
        self.hi_there["command"] = self.th.start()
        self.hi_there["fg"] = "green"
        self.hi_there.pack(side="top")

        self.hi_there = tk.Button()
        self.hi_there["text"] = "STOP"
        self.hi_there["command"] = self.stop
        self.hi_there["fg"] = "green"
        self.hi_there.pack(side="top")

        self.quit = tk.Button(self, text="QUIT", fg="red",
                              command=self.master.destroy)
        self.quit.pack(side="bottom")

    def say_hi(self):
        if self == 1:
            test = True
            x = 1
            while test:
                print(x)
                x = x + 1
                sleep(1)
                if x > 5:
                    break


    def stop(self):
        test = False

root = tk.Tk()
app = Application(master=root)
app.mainloop() """