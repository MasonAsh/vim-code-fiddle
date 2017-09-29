# vim-code-fiddle
Quickly create and run small pieces of code within vim without needing to setup a project

Have you ever wanted to quickly test a small snippet of code without going through the hassle of setting up a new project and going back and forth between the text editor and the terminal? This plugin solves that problem!

# Usage
Create a new code fiddle using the following command:
```
:CodeFiddleNew <filename with extension>
```
Code fiddle will create a new file with some initial contents depending on the language.

For example, `:CodeFiddleNew test.cpp` will create a file with the following contents:
```
#include <iostream>

int main()
{

}
```

From there you can go ahead and edit the code, and when you're ready to run it, use the following command:

```
:CodeFiddleRun
```

This will compile the code, and if compilation succeeded, will run the program.
