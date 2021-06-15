from tkinter import *
from tkinter.font import BOLD
from PIL import ImageTk, Image
from tkinter import filedialog
from subprocess import Popen,PIPE
import subprocess
subprocess.run(["bison", "-y", ".\lang.y", "-d"])
subprocess.run(["flex", ".\lang.l"])
subprocess.run(["gcc", ".\lang.c", ".\y.tab.c", ".\lex.yy.c"])

root = Tk()
root.title(" Mini Compiler-GUI ")

root.columnconfigure(0, weight=1)
root.columnconfigure(1, weight=2)


#---------------------Functions------------------

#Run The code in the code text area
def run():
  file_erros = open("errors.txt", "w")
  file_quad = open("quadruples.txt", "w")
  file_symtable = open("SymbolTable.txt", "w")
  file_erros.write("")
  file_quad.write("")
  file_symtable.write("")
  file_erros.close()
  file_quad.close()
  file_symtable.close()

  #Clear  window
  error_output.delete("1.0", END)
  symtable_input.delete("1.0", END)
  quadruples_input.delete("1.0", END)
  #get the code from the code text area
  inputCode = code_input.get("1.0",'end-1c')
  input_to_bytes = bytes(inputCode, 'utf-8')
  p = Popen("a.exe", stdin=PIPE,stdout=PIPE)
  out = p.communicate(input_to_bytes)
  file = open("errors.txt", "r")
  errorMessage = file.read()
  error_output.insert(END, errorMessage)
  file.close()
  print(errorMessage)
  if errorMessage == "":
    file = open("quadruples.txt", "r")
    quadruples_input.insert(END, file.read())
    file.close()
    file = open("SymbolTable.txt", "r")
    symtable_input.insert(END, file.read())
    file.close()



#Import a file
def import_file():
  root.filename = filedialog.askopenfilename(initialdir = 'Desktop', title = 'Select a File', filetypes = (('py files', '*.txt'),("text files", "*.txt"),('all files', '*.*')))
  if root.filename != '':
    code_input.delete("1.0", END)
    file = open(root.filename, "r")
    code_input.insert(END, file.read())


#Exit Program
def exit():
  root.quit()
	


#-------------------Frames And Labels--------------------------------------

menu_frame = LabelFrame(root, padx=0, pady=0 )
menu_frame.grid(row=0,column=0,stick='NESW')
ide_frame = LabelFrame(root, padx=0, pady=10 )
ide_frame.grid(row=1,column=0)
ide_frame.configure(bg="white")

#Code Frame
l = Label(ide_frame,text = "My IDE",font=18,bg='white')
l.grid(row= 1, column=0)
code_frame = LabelFrame(ide_frame, padx=6, pady=0 )
code_frame.grid(row=2, column=0,sticky=W)
code_frame.configure(bg='black')

#Symbol Table Frame
l1 = Label(ide_frame,text = "Symbol Table",font=18,bg='white')
l1.grid(row= 1, column=1)
symtable_frame = LabelFrame(ide_frame, padx=6, pady=0 )
symtable_frame.grid(row=2, column=1,sticky=W)
symtable_frame.configure(bg='black')

#Quadruples Frame
l2 = Label(ide_frame,text = "Quadruples",font=18,bg='white')
l2.grid(row= 1, column=2)
quadruples_frame = LabelFrame(ide_frame, padx=6, pady=0 )
quadruples_frame.grid(row=2, column=2, sticky=W)
quadruples_frame.configure(bg='black')

#Error Frame
error_frame = LabelFrame(ide_frame, padx=0, pady=10 )
error_frame.grid(row=3, column=0,sticky=W,columnspan=3)
error_frame.configure(bg='black')


#--------------------------Input Text----------------------------------------
#Code Text Area
code_input = Text(code_frame, height = 25,width = 50,bg = "black",fg="green",insertbackground='white')
code_input.grid(row= 1, column=0,sticky=W,columnspan=1)

#Symbol Table Text Area
symtable_input = Text(symtable_frame, height = 25,width = 50,bg = "black",fg="white")
symtable_input.grid(row= 1, column=1,sticky=W)

#Quadruples Text Area
quadruples_input = Text(quadruples_frame, height = 25,width = 45,bg = "black",fg="white")
quadruples_input.grid(row= 1, column=2,sticky=W)

#Error Text Area
error_output = Text(error_frame, height = 8,width =152,bg = "black",fg="red")
error_output.grid(row= 2, column=0,columnspan=3,sticky="NESW")


#----------------------------Buttons----------------------------------------------
run_button = Button(menu_frame, text = 'Run', bg= '#28275C', fg = '#FFFFFF', command=run, width= 15, height=2,padx=5)
run_button.grid(row=0, column=0)

#Import File Button
import_button = Button(menu_frame, text = 'Import',bg= '#28275C',fg = '#FFFFFF', command=import_file, width= 15, height=2,padx=5)
import_button.grid(row=0, column=1)


#Exit Button
exit_button = Button(menu_frame, text = 'Exit',bg= '#28275C',fg = '#FFFFFF', command=exit, width= 15, height=2,padx=5)
exit_button.grid(row=0, column=3)

root.mainloop()
