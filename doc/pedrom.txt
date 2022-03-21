       Title: PedroM
     Version: 0.83
 Platform(s): TI-92+, TI-89, V200 and TI-89 Titanium
      Author: Patrick Pelissier (PpHd)
    Web Site: http://www.yaronet.com/t3/
      E-Mail: patrick.pelissier@gmail.com
Release Date: 2010/11/03

---------
0.Licence
---------

  PedroM   - Copyright (C) 2003-2010 Patrick Pelissier
  PreOS	   - Copyright (C) 2002-2009 Patrick Pelissier
  Side     - Copyright (c) 2002, 2005 Clement Vasseur.
  MD5      - Copyright (C) 1999, 2000, 2002 Aladdin Enterprises.
  ExtGraph - Copyright (C) 2001-2002 Thomas Nussbaumer
  TIB Install - Copyright (c) 2000-2004 Julien Muchembled.
  Unpack   - Copyright (C) 2004 Samuel Stearley 
  bsearch  - Copyright (c) 1990 Regents of the University of California.
  tigcclib - Copyright (C) 2000-2003, 2009 Lionel Debroux, Zeljko Juric, Thomas Nussbaumer, Kevin Kofler and Sebastian Reichelt

  This program is free software ; you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version. 
  
  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
  FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details. 
  
  You should have received a copy of the GNU General Public License along with
  this program; if not, write to the 
  Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.

  PedroM may also be 'linked/pasted' with non-GPL extra code which is distributed under
  its oww licence:
  STDLIB   -  Copyright their respective authors (Non commercial use). See preos for details.
  It is a binary blog that doesn't affect in any way PedroM: PedroM doesn't
  depend on it in any way and it's not considered a 'derived work'.

  This copyright does *not* cover user programs that use PedroM
  services by various system calls - this is merely considered normal use
  of PedroM, and does *not* fall under the heading of "derived work".

  NOTE! If you build PedroM with the CAS engine, the resulted binary shall be
  distributed under the GPL v3 or above:
  GMP      - Copyright 1991-2009 Free Software Foundation, Inc..
  MPFR     - Copyright 1991-2009 Free Software Foundation, Inc..
  MAYLIB   - Copyright 2005-2009 Patrick Pélissier

  To build PedroM you have to use some tools which are distributed under their own license.

--------------
I.Introduction
--------------

        PedroM is a complete new Operating System (OS) for Ti-68k calculators. It doesn't use any code from Texas Instruments OS, Advanced Math Software (AMS). The goal was to create an OS useable on real calcs, which can run safely more than 97% of the assembly programs designed for AMS 1.0x. So that, I was obbliged to rewrite many romcalls of the original OS. The rewritten romcalls are often faster, but always smaller: only 192K of Flash Rom are reserved for the system (64K for the boot, 8+8K reserved by the hardware, 48K+64K for PedroM itself). As a consequence, there is plenty of Flash memory available (228 Kbytes of RAM and 1900 Kbytes of Archive). Of course, this OS sets the hardware protection (in RAM and in ROM) off. But all the assembly programs use either self modifing code, or data in code segment. So only the PedroM programs would be able to be executed in ROM. AMS Flash Application is not planned to be supported.
        
        The Ti link protocol is not complete: you can't receive/send backup. Other things should work with TILP, TI-GRAPH LINK or TI CONNECT.

        PedroM has the latest PreOS core as a built-in, so you don't need to install a kernel extender. It can also run natively PPG programs (See http://tict.ticalc.org for more infos about PPG programs). In conclusion, you can run:
                - Nostub Programs.
                - Kernel Programs (version 2, 3, 4 & 5) -See "Kernel History" in PreOS.txt.
                - PPG Programs.
                - Pack Archive Programs.
        Kernel v1 programs can be converted using 'ck1tok2' program to kernel v2 so you can even use kernel v1 with PedroM (Sorbo Quest! Lovely.) but this feature is limited for the HW1 calculators. If you try to run such programs without converting them, they may fail or report that a library is missing: convert them.
	There is an emulator of old calculators (92+ and 89) for V200 and Titanium so that you can run kernel programs which are not designed for such calculator. However, this emulator doesn't support nostub programs: you must find other programs to convert them (For example, ghostbuster).
        
        Many romcalls have been rewritten (>400). Many program work. TSR programs won't work since EV-hook doesn't work (In fact, EV_hook works but there is no AMS like application installed, so it does nothing since there is no event). PedroM is detected as AMS 1.01 by nostub programs but kernel programs will detect AMS 1.48.
        'stdlib' is also a built-in library (If enable)
        
	It can also be linked with GMP( http://gmplib.org), MPFR (http://www.mpfr.org) and MAYLIB (a custom made library) which helps PedroM to provide a symbolic engine (Not a CAS, but a start). To run the symbolic engine, you have to build PedroM with it by using the command : make CAS=1 or use a compiled binary. Then you enter the symbolic engine by typing the command 'zs'. You'll enter a new shell of command with the following properties. Note that this shell is not the final interface: it is used for beta testing the symbolic engine. You can type any mathematical expression, then press ENTER to evaluate it (For example, 2*x-x is simplified into x).  The evaluation should be always exact except for a set of measure zero. You can enter arbitrarily long integer, fraction or floats (For example, 500!-3/2). The precision of the floats can be changed anytime by using the prec function. Note that the floats used in this mode are based on MPFR and are much more reliable than the floats used outside the symbolic engine.
	This symbolic engine is far less complete than AMS but is in general faster.

-------------------------------------
II.The command line prompt: the shell
-------------------------------------

        Contrary to AMS, PedroM looks like a unix shell. You can receive any files (sent throught the link port) in this shell, just like in the AMS Home application. The provided shell is far from perfect, but a "sh" compliant shell increases the OS size too much (TBC).
        
        A. SPECIAL KEY LIST:
        --------------------

        ENTER:  
                You enter a command in the prompt, and you validate it by pressing ENTER.
        UP/DOWN:
                There is an history of the last used commands.
                Press Up/Down to select a previous command (Up to 10 previous commands).
        LEFT/RIGHT:
                Select current character of the prompt.
        [2nd]+LEFT/RIGHT:
                Go to the beginning or the end of the prompt.
        ON:     
                Auto completion of the current command.
                It searchs in the internal commands, in the folders and in the files of the current path. If there are more than one command which can complete the line, it puts as much char as possible. It no char can be put, it displays a menu with all the possible commands (except if you are under very low memory condition).
        F1-F8:
                Paste the memorised command (See Environnement variables).
        ON-ESC:
                Abort current program.
        [2ND] + [APPS]:
                Restart another Shell Command (Switch current task).
	[DIAMOND] + F1-F8:
		Go to background process #0 to #7.
        [CLEAR]:
		Erase the current input, or if there is no current input, clear the screen.
                
        B - INTERNAL COMMANDS:  
        ----------------------

        They are many built-in commands:

	     a.FLASH UPDATE:
	     ---------------

        + 'install product code': Install a signed Product Code using the Boot code (ie reinstall AMS). This command isn't fully displayed in the help. This command should be safe.
        + 'install tib'		: Install an unsigned Product Code. This command isn't fully displayed in the help. It uses an internal function to reinstall a new tib. This command is the only way to update PedroM.
        + 'install format'	: Bad name for such a command (It is too avoid auto-completion). Nevertheless this command erases all the archived files of your calculator and does a reset. The original version of stdlib is reinstalled too. Don't perform this command too often since it erases all the flash.

	     b. MISC:
	     --------

        + 'help'        : display all the internal commands.
        + 'clear'       : Clear the screen.
        + 'echo'        : Display the given string.
                        Ex: echo "Hello world !"
        + 'more'        : Display else stdin or the given file, stopping itself every 14 lines.
			Ex: ls -l | more
	+ 'cat'		: Display the given files (in stdout). '-' is the stdin file.
			Ex: echo Hello >toto
			Ex: echo World |cat toto - toto
	+ 'menu'	: Display a menu of the different given arguments
	  		Return as output the selected argument.
			Ex: menu "Choice1" "Choice2" "Choice3"
	
	     c.SYSTEM:
	     ---------

        + 'flags'       : Set the internal flags of Pedrom.
                        Use:    flags   optionA=1 optionB=0 [...]
                        Options may be:
                        - AutoArc:	The sent files are automaticly archived if set.
                        - OffSwitch:	Instead of turning off the current running program, it switches and starts another Shell Command.
                        - GetKeySwitch:	If you press [2nd]+[APPS] inside a program which uses the internal functions ngetchx/GKeyIn, it switches and starts another Shell Command.
			- StatusError:   The reported errors uses the Status Help instead of a dialog box. 
        + 'clean'       : Clean the system (Unrealloc Kernel files, delete Twin Files, and free all handles which are not in the VAT). Check if the system is not corrupted, and does a reset if it is. Erase all background process too!
        + 'reset'       : Reset PedroM (Archive won't be lost).
        + 'mem'         : Display the remaining memory.
        + 'hexdump'     : Do a dump of the memory. Usefull for debugging.
                        Ex: hexdump 0x400000

	      d.FILES:
	      --------

        + 'cd'          : Change the current directory.
                        Ex: cd toto
        + 'arc'         : Archive a file (Put a file from RAM to Flash Rom). 
                        Ex: arc sma
        + 'unarc'       : Unarchive a file.
                        Ex: unarc sma
        + 'ls'          : List the current directory. Options : 
                        '-l' : to have some details.
                        '-h' : to see the 'home' directory.
        + 'mkdir'       : Create a new directory.
                        Ex: mkdir toto
        + 'rmdir'       : Delete a directory. All the files in the directory are deleted.
                        Ex: rmdir toto
        + 'rm'          : Delete a file.
                        Ex: rm temp
        + 'rmarc'       : Delete an archived file.
                        Ex: rmarc temp
        + 'mv'          : Move/Rename a file (SrcName DestName).
                        Ex: mv tictex shell
        + 'cp'          : Copy a file (Srcname DestName).
                        Ex: cp main\tictex system\shell
        + 'sendcalc'    : Send a file to another calc. Works even with AMS calcs!
                        Ex: sendcalc tictex
        + 'getcalc'     : Get a file from another calc. Works even with AMS calcs!
                        Ex: getcalc tictex
        + 'read'        : Read from the keyboard (stdin) and put the chars in variables.
                        Ex:     :>read x y z
                                Hello world !
                        Now x = "Hello", y = "world" and z = "!".
        + 'unppg'       : Extract a PPG file and add the extracted program to the VAT.
                        Ex: unppg db92ppg db92

	       e.PROCESS:
	       ----------

        + 'ps'          : Display all the background processs. The current process is not listed. It displays the PID (The number to give to kill/exit command), the size used by the system to save the process and its probable name.
        + 'kill'        : Kill a background process, given its PID (See ps for PID).
                        Ex:     kill 1
        + 'exit'        : Stops the current process and restore a background process.
                        Syntax:         exit      [PID]
                        If you don't specify the PID, it will restore the latest process.
			If there is no more background process, it restarts another one.

	       f.APPS:
	       -------

        + 'side'        : Starts SIDE (Built-in application).
                It is a text editor. Here are the keys :
                  [2nd]+[LEFT]  : jump to beginning of line
                  [2nd]+[RIGHT] : jump to end of line
                  [<>]+[LEFT]   : Next left word
                  [<>]+[RIGHT]  : Next right word
                  [2nd]+[UP]    : page up
                  [2nd]+[DOWN]: page down
                  [<>]+[UP]: jump to first line
                  [<>]+[DOWN]: jump to last line
                  [SHIFT] + arrow keys: select text
                  [CLEAR]: clear to end of line
                  [2nd]+[CHAR]: characters table
                  [APPS]: Display secondary screen (See config)
                  [ESC]: close file and prompt for a new one
                  [2nd]+[QUIT]: exit
                  [2nd]+[OFF] or [<>]+[ON]: power off
                  [<>]+[x] : cut
                  [<>]+[c](Ti-92+) OR [<>]+[y](Ti-89): copy
                  [<>]+[v](Ti-92+) OR [<>]+[z](Ti-89): paste
                  F1 - Build - save the file and launch the compiler.
                  F2 - Exec - save the file and executes the compiled program.
                  F3 - Goto - go to the given line
                  F4 - Find - prompt for a string to be searched for
                  F5 - Replace - prompt for a string to be replaced for
                  F6 - Config - open the config screen
                  F7 - About - show the about screen
		  And also [2nd]+[Switch] and [diamond]+F1-F8: See the shell keys for details.
                -- Config --
                Build: name of the program that runs with F1 (build) '!' is the text filename.
                Exec: name of the program that runs with F2 (Exec) '!' is the text filename.
                2nd text: name of the text file to open with APPS.
                Auto insert closing brackets: Yes/No
                Auto indent: insert spaces when [ENTER] is pressed
                Key repeat delay and rate let you configure the cursor speed. 

	+ 'zs': Starts the Symbolic engine (Built-in application) if built.
	  You'll enter a new shell where you can write any mathematical expression, then press ENTER to evaluate it: for example, 2*x-x is simplified into x.
	  The evaluation should be always exact except for a set of measure zero.
 	  You can enter arbitrarily long integer, fraction or floats: for example, 500!-3/2. The precision of the floats can be changed anytime by using the prec function. Note that the floats used in this mode are based on MPFR and are much, much reliable than the floats used outside the symbolic engine.
	  You can save some values inside 26 variables : 'a' to 'z' (For example, 2+x STO a    -- Note that STO is the STORE character used to store on AMS in the variables) and use them latter (For example, expand (a^2)). To delete a variable, store nothing in it (Example: STO a)
	  The available commands are: 
	       	 * approx(expr,prec): Approximate exactly an expression up to prec digits in base 10 using rounding to nearest.
		 * degree(expr,var) : Degree of the expression view as a polynomial of var
		 * eval(number)     : Set the number of times the evaluation must rereplace the variable by their value 
		 * mem()	    : Available memory
		 * expand(expr)	    : Expand the expression
		 * evalf(expr)	    : Evaluate the expression as a floatting point.
		 * evalr(expr)	    : Evaluate the expression as a range of reals.
		 * factor(expr,var) : Factorise expr view as a polynomial of var (Performs only square free algo).
		 * trig2exp(expr)   : Transform the trigonometric functions into their exponentiels counter parts.
		 * exp2trig(expr)   : Transform the exp functions to the trig ones.
		 * trig2tan2(expr)  : Transform the trig functions in function of tan()/2
		 * tan2sincos(expr) : Transform tan into sin()/cos()
		 * partfrac(expr,var): Returns the partial fraction decomposition of expr of the variable var
		 * pow2exp(expr)    : Transform power into exp(log())
		 * rationalize(expr): Rationalize an expression.
		 * normalsign(expr) : Normalize the even/odd functions.
		 * rectform(expr)   : Rectangular complex form of an expression.
		 * combine(expr)    : Combine an expression.
		 * eexpand(expr)    : Expand the exponentiels
		 * sign2abs(expr)   : Transform sign() into abs(x)/x
		 * texpand(expr)    : Trigonometric expand
		 * tcollect(expr)   : Trigonometric collect
		 * indets(expr)	    : List of the indeterminates of an expression.
		 * subs(expr,var,val): Replace var by val inside expr
		 * series(expr,var,order): Series of expr in var up to order order
		 * prec(number)     : Set the precision of the floatting point to number bits (default 113)
		 * intmode(number)  : Compute everythin in Z/numberZ
		 * domain(real|complex|integer): Set the default domain for NEW variables.
		 * write(string, expr): Write expr into the file which filename is string.
		 * read(string)	    : Read the file which filename is string and returns the corresponding expression.
		 * help()	    : Display help

		g.EXTRA-INFORMATION:
		--------------------

        Wildcards '*' and '?' are supported for the extra arguments: use 'arc *lib' to archive all the libraries.
        Variables are supported just like in Unix Script (But replacing vars may throw errors):
                {"Hello","world"}->x
                echo "${x[1]} ${x[2]}"
                "ls -l"->ls
                $ls
        Redirection is supported just like in Unix Shell:
                ls -l >dummy 2>error
                mem >>dummy
                ls -l | more
                read x y <hello
	Alias are supported too: all string variables in folder 'system' are assumed alias (FIXME: Conflict with env variables?).
	      "ls -l"->system\l
	      l
                        
        C - PROGRAMS:
        -------------

        If you want to run a program (designed for PedroM or AMS), just enter its name, and press ENTER. It cans run ASM programs directly. You don't need to install a kernel (By the way, no kernel can be installed!). It cans also run the PPG directly. So you can delete the launcher. You don't need to write the braquets '(' and ')'.
        
        D - CALCULATOR:
        ---------------

        Even if PedroM isn't designed to be a calculator, it would be quite annoying if you can't do any calcul with it. So you can enter a simple math calcul in the command line prompt, and it evaluates it:
        Example:
                2+2
                2E145*145
                -1452.3         ("ans - 1452.3")
                1452.23*256.32->x
                x*25.236->y
                x
                y
                1->x
                y
                1+x->x
                x
        For the moment, only + / * - -> exp ln sqrt worked (and external fonctions).
        As a consequence, you can call a program like with AMS: "shl()" works, but it returns a random float since it doesn't support the PedroM convention.
        
        dim(LIST) returns the size of the list. dim(STRING) returns the size of the string.
        getkey() pauses the system waiting for a key. It returns the Key code.
        time()	returns the current time (from the boot of the calc).
	testd(string) returns true if string exists as a directory.
	testf(string) returns true if string exists as a file.
	        
        NOTE(1): "tictex()" won't work since it doesn't create a twin entry.
        NOTE(2): If an error arrived, some variables may be locked (ie can't be used). You can unlock them by calling 'clean'.
        NOTE(3): Func arg '25*x->f(x)' is not yet supported.

        E - Script:
        -----------
                
        A script is a text file which contains a list of commands to execute.
        The first line must be " #!PedroM ". All lines which begins with # are comments. Other lines are commands, just like in the shell. The script arguments are stored in a created variable: system\args, which is a list var.
        A special script with no argument is launched when PedroM starts: its name is 'system\start'.

	A script supports also some extra commands which are not available from the shell:
		+ exit:	Exit from the script instead of exiting the process.
		+ if/else/elif: Execute block if condition is true:
			if CONDITION
			 <
			  CODE
			 >
			elif CONDITION
			 <
			  CODE
			 >
			else
			 <
			  CODE
			 >
		+ while: Execute block until condition is false:
			while CONDITION
			 <
			  CODE
			 >

	This script language is not efficient at all.

	F - System variables
        --------------------
	
	Environnement variables are string variables stored in system folder (just like alias... what a bad design!):
	They are mainly:
		+ system\start	:	Script to execute when the system boots (Press ON at boot time to avoid running it).
		+ system\apd	:	Apd value (String Number). Set the current value for the Auto Power Down timer (in seconds). Valid values are from 10 to 1000 (Other values won't be accepted). Warning: It is a string, not a float!
		+ system\path	:	Set the current PATH. If a file is not found inside the current (and if there isn't any given folder), it will search in the path. It is a list of strings.
		+ system\args	:	List of the arguments given to a script. It is a list of strings. It is a local file to a script (ie it is different for each script).
		+ system\fkey[n]:	String to put if F[n] is pressed.
		                        Ex: '"stdlib"->system\fkey1' : When you press F1, "stdlib" is pushed instead.
	                	        Ex: '"ls -l;"->system\fkey2' : With F2, "ls -l" is executed. Putting ';' as the last char means execute the command after putting it.
		+ system\font	:	Font used to display the shell (0->Small, 1->Medium, 2->Large). Warning: it is a string, not a float.
		+ system\linklog:	Filename (as a string) used to store all the link communication with the PC.
		  			Warning: this file may grow at an unexpected fast rate!

	The system folder shall be used to store the config files of all the applications (But not as string variables).
	The main folder shall be considered as the HOME folder of the user.
		
----------------
III.Installation
----------------

	Either you have the OS key, and you can build PedroM using it to sign it; then you can use any link program to send the OS.

	Or you have to use the old way:
	See http://www.ticalc.org/archives/files/fileinfo/368/36829.html
	Or  http://www.ticalc.org/archives/files/fileinfo/154/15489.html
	Please read carefully their documentation before doing anything.

----------------
IV.Build PedroM
----------------

        0. You need:
		+ the latest gcc4ti		 (See http://trac.godzil.net/gcc4ti/ ) or the latest tigcc (See http://tigcc.ticalc.org/ ).
                + PedroM sources.		 (See http://www.yaronet.com/t3 )
                + PreOS sources v1.0.7 or above. (See http://www.yaronet.com/t3 )
		+ A Unix like environnement      (ie. it needs cygwin/mingw for Windows).

	1. Install archives:
	   	In the same directory, extract PedroM sources and PreOS sources.
	   [OPTION]: Copy/Update the file gmp-x.x.x.tar.bz2, mpfr-x.x.x.tar.bz2 and may-x.x.x.tar.bz2 into the directory src/lib of PedroM
	   [OPTION]: Install the OS keys (0001.key, 0003.key, 0008.key and 0009.key into the directory bin/keys of PedroM.

        1. Build PedroM:
		a. Open a shell command.
		b. Go to the PedroM source directory.
		c. Build it:
		     make # Produce a TIB without the keys, some signed .??u with the OS keys.
		   [OPTIONS]: In $PEDROM/src, run:
			make PREOS=$(MY_OWN_PREOS_DIRECTORY)
		 	make GPL=1  # Pure GPL version without stdlib (For GPL extremist)
			make CAS=1  # You need to have copied GMP / MPFR / MAYLIB into the lib directory

--------------
V.Boot & Reset
--------------

        In PedroM, there are 2 kinds of reset:
                + soft reset which doesn't destroy your RAM : 'Address Error', 'Protected Memory', ... do such kind of reset. I recommended highly to do a 'clean' command before continuing. PedroM can't do it itself because this command may crash the calculator.
                + hard reset : the RAM is totally reset. Only the archive files are kept.

        If you press ON during the end of the booting process (between the black screen and the white screen), PedroM will do a hard reset which doesn't start the script 'start'. Do no kept ON pressed during the second reset, otherwise, it will do a 3rd reset, and so on.
                
-------
VI.FAQ
-------

Q: Why should I use PedroM instead of AMS?
A: For 4 main reasons: 
        + PedroM is free software!
        + There is plenty memory free (Both Flash and RAM).
        + There are less dramatical bugs than AMS (ie you can't overpass the Hardware Protection by software.).
	+ It is updated contrary to AMS.

Q: Why should I use AMS instead of PedroM?
A: For 2 main reasons: 
        + AMS is less buggy.
        + AMS is the reference: it should be compatible with all programs.

Q: Is there a Window Like environnement?
A: Some window'like environnements should have been developped for PedroM. If you want to do one, fell free to contact me.

Q: Some programs don't work under PedroM. A program tells me 'Romcall xxx not available'. What can I do?
A: Nothing. Just report me the program, and maybe I can fix it.

Q: Some programs crash under PedroM. What can I do?
A: Report me the program. If it is a kernel program, it is certainly a bug in PedroM. PedroM should be compatible with all kernel programs (on HW1, at least)... If you have a HW2, you may have some problems with GrayScales with old programs. TiGb can't be run because it uses a dirty hack to get a 70K page. There may be also some new problems with HW3.

Q: A program crashes, and I can't run it anymore.
Q: The calculator don't have any memory left.
A: Call 'clean' command. Then retry it. If it crashes again, it has been corrupted. Resend it to PedroM.

Q: I change the batteries, and PedroM resets.
A: Yes. I don't have written the code for avoiding this on HW2!

Q: I can't install unios/preos/doorsos/teos!
A: There is already a kernel in PedroM! You don't need to install a new one. Moreover kernels use many dirty hacks which are not compatible with PedroM.

Q: What is 'stdlib'?
A: Lock at PreOS documentation.

Q: Why don't you do a multi-tasking OS? Why not Linux?
A: I personnaly think that if you want to do a multi-tasking OS, you should have at least a MMU to protect the tasks. Ti-92+ doesn't have a MMU, so a single-tasting OS is more suitable. Install Prosit if you still want such a program. Moreover the RAM is too small to create a good multi-tasking OS.

Q: I send a file and it seems to work fine, but when I list the files, I can't see it.
A: Check if the file hasn't been added to another folder.

Q: Why a TIB and not a 9xu?
A: 9xu files have some secrets I don't know. I know the format of the TIB files enought to create a good TIB. 
 
Q: Your completion algorithm is quite good, but I want to add my own words to the list.
A: You can do it by creating some dummy files in a dummy folder.
   For example, your words are: toto, titi, tutu.
   In the shell, enter this:
        :>1->dummy\toto
        :>1->dummy\tutu
        :>1->dummy\titi
   to create some dummy vars (You can archive them). Then, add dummy folder to the path:
        :>setpath dummy [...]
   When you press, [t] then [ON], you will have your own words in the list. Magic, no?
   
Q: What is PedRhum?
A: PedRhum was a modified version of PedroM by Extended. It allows you to use PedroM without replacing AMS (Just like running Linux from DOS), so you can test PedroM. It uses some dirty hacks so the bugs must be returned to Extended himself, who may forward me if needed.
   
Q: I want to run program 'mem', but it is also an internal command, and I can't run it.
A: Run it like this: main\mem or mem()

-------------------
VII.Special Thanks
-------------------
        
        - Johan  <johei804@student.liu.se> for his precious hardware doc.
        - Rusty Wagner <river@gte.net> for Vti emulator.
        - Zeljko Juric <Zeljko@tigcc.ticalc.org> for tigcclib.
        - Julien Muchembled <Julien.Muchembled@netcourrier.com> for his tools.
        - Olivier Armand (ExtendeD) <ola.e-ml@wanadoo.fr> for checking (often!) my code.
        - WORMHOLE <ti_crackers@hotmail.com> for OpenOS.
	- Fosco255 for his tests on V200.
	- Martial Demolins (Folco) for all his tests and requests.
	- All the people who helped factoring the OS keys.

        - And a billions of thanks to all the beta testers!
