# vim2term
a vim/nvim plugin to simply send lines to terminal

This plugin is tested on windows 10 nvim. I am python and R user. So python, ipthon, R and radian are tested.

## Main function
###  Send line/lines
You can send one single line, code blocks and selection to the terminal (default binding `<C-Enter>`)
1. send one line 
    in the normal mode, press Ctrl-Enter
2. send code block
    put the cursor at the first line of a code block, press <C-Enter>

The block is defined as follows:
```python
def foo():
    return 1

a = [1,2,
    3,4,5]

a = [1,2,
    3,4,5
]

a = (1,2,3,
    4,5
)

for i in range(10):
    print(i)

```
```r

foo = function(x){
    return 1
}
```

```vimscript
for i in list:
    echo i
endif

```

3. If the automatic code block is not what you want.  You can send selection to the terminal.

Use visual mode to select the lines and press Ctrl-Enter to send selection to the terminal.

> **Note :If your selection is within the same line, you can send the selected piece of code to the terminal. If your selection covers more than 1 line, the complete lines are sent.**

### mulitiple terminal Binding
1. This plugin support multiple terminals binding. The binding happens when you press Ctrl-Enter. If no terminal is binded to the current buffer, this plugin will automatically bind the current buffer to the most newly opened terminal. So you can bind each buffer to different terminals and send code respectively. (say you have a python file and R file. you can open a python session and R session in terminal. python code goes to the python session and R code goes to the R session.) 

2. If the automatic binding didn't bind the buffer to the terminal you want you can use the `:LinkTerm` to change binding. say the terminal buffer number you want to bind is 3, put the cursor in the code buffer, type `:LinkTerm 3` to link the buffer to the terminal.

## Usage
0. put the following line to your vimrc file 
```
nmap <C-Enter> <Plug>SendBlock
vmap <C-Enter> <Plug>SendSelection
```

1. open a code file , say hello.py
2. use `:split` to split the window
3. open a terminal using `:terminal`, type `python` or `ipython` in the termial to start a python session
4. now go back to the file and put the cursor at the line you want to send, press <C-Enter>

** for multiple terminal binding**

5. spit a window, open a file, say hello.R 
6. split a window and open terminal
7. go back to the file and put the cursor, press Ctrl-Enter

Happy vim! Feel free to  star and fork.

