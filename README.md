# shfnlib
The Korn/Bourne Shell Function Library: built to normalize and enhance ksh88, ksh93, and bash scripts.

Tested on AIX 4.3+, Linux, and Cygwin. It includes several pieces of code to normalize commands accross the different shells. The library has some of my more creative/crazy functions like hashes, array stacks, and more..

Before attempting to use this library run "functions-test-1.sh".
If you find any errors please send me an email.
All code is developed using test blocks. i.e. create the test first, then the code, if the code passes the test, then the code must be correct.
Check out Scrum and "eXtreme programming" techniques. 
The include file "function-1.sh", the code block test script "function-test-1.sh", and the docs are all generated with genfunclinklist-0.sh

The library was creating using the awsome editor code-browser version 2.18

http://tibleiz.net/code-browser/index.html

Check out the main project page as well as some of my other projects at

http://scriptvoodoo.org/Projectsshfnlib.html

## A few notes on the hashes/associative arrays:
* the other shells still don't natively support hashes
* this library was build before bash 4.0.0, before bash supported hashes
* bash still doesn't support multidimensional hashes, this library does.

## todo
* update lib to take advantage of new bash 4 features.
