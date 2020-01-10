# vim2term
a vim/nvim plugin to simply send lines to terminal

This plugin is tested on windows 10 nvim.

## Main function
1. Send one single line to the terminal (default binding <C-Enter>)

2. if the cursor is at the first line of a code block, send to block to the terminal (default binding <C-Enter>)
The block is defined as follows:
```python
def foo():
    return 1

a = [1,2,
    3,4,5]

a = (1,2,3,
    4,5
)

```
```r

foo = function(x){
    return 1
}
```

3. If the block this plug automatically find is not what you want. You can use the visual mode to select the lines and press <C-Enter> to send selection to the terminal.
Also please don't forget to contact me to help improve this plug.

4. If in the visual mode, your selection is within the same line, you can send the selection code to the terminal.
However, if your selection covers more than 1 line, the complete lines are sent.

5. This plugin support multiple buffer and multiple terminal binding. and will automatically bind the buffer you are editing to the most newly opened terminal. Open terminal using `:terminal`. So you can open two files and two terminals and work with them simutaneously. (say you can a python file and r file. we can open a python session and R session in terminal. python code goes to the python session and R code goes to the R session.) 

6. If the automatic binding didn't bind the buffer to the terminal you want you can use the `:LinkTerm` to change binding. say the terminal buffer number is 3, put the cursor in the file you are editing, type `:LinkTerm 3` to link the buffer to the terminal buffer.

Happy vim! Feel free to  star and fork.

