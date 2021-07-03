# 从gcc到make和makfile
#make

参考:
- [ ] [Linux GCC常用命令 - ggjucheng - 博客园](https://www.cnblogs.com/ggjucheng/archive/2011/12/14/2287738.html)
- [ ] [GCC 参数详解 | 菜鸟教程](https://www.runoob.com/w3cnote/gcc-parameter-detail.html)

从接触Linux开始,就不可避免的需要编译自己程序
这就要说到本文的第一个主角gcc

什么是gcc[GCC - 维基百科，自由的百科全书](https://zh.wikipedia.org/wiki/GCC)
原名为**GNU C语言编译器**（**GNU C Compiler**） 注意 本质上gcc 是一个编译器

编译器就是把我们写的代码,编译为CPU认识的二进制代码
这里通过一个基础的编译流程来讲解编译器具体是干什么的

⚠️测试环境:
OS : Mac OS
GCC : 
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/2D5A242F-2170-4DD2-A623-21FE3F52D87E.png)

```c
#include <stdio.h>

int main(void){
	printf("Hello world!\n\r");
	return 0;
}
```

早期的计算机,是通过打孔纸带进行二进制的编程输入的,但是太过繁琐且对人类很不友好,并且编写效率很低

为此人类进而开发出了,汇编语言和针对汇编语言的编译器,可以较为抽象的表达代码.

用汇编写的上面的Hello world是这样子的
```x86asm
data segment ;数据段
    string db 'Hello,World!$'
data ends
code segment ;代码段
assume cs:code,ds:data
start:
    mov ax,data ;获取段基址
    mov ds,ax ;将段基址送入寄存器
    mov dx,offset string
    mov ah,9
    int 21h
    mov ah,4ch
    int 21h
code ends
end start
```

在使用了汇编之后,发现还不是很方便,进而开发出了人类变成语言上的一个里程碑式的语言,大名鼎鼎的C语言,和开发出汇编一样,同时也有要给针对C的编译器gcc

基础的编译流程就是gcc将c编译成汇编,汇编在编译为可以直接被cpu识别运行的二进制代码

* **-o**
指定输出的文件名
```bash
gcc hello.c -o hello_world
```

* **-E 预处理** 
C语言代码在交给编译器之前，会先由预处理器进行一些文本替换方面的操作，例如宏展开、文件包含、删除部分代码等。
在正常的情况下， gcc 不会保留预处理阶段的输出文件，也即.i文件。然而，可以利用-E选项保留预处理器的输出文件，以用于诊断代码。-E选项指示 GCC 在预处理完毕之后即可停止。
默认情况下，预处理器的输出会被导入到标准输出流（也就是显示器），可以利用-o选项把它导入到某个输出文件：
```bash
gcc -E hello_world.c -o hello_world.i 
```
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/B6824F5E-0A57-44B8-AAC1-36B320EEC33C.png)
⚠️全部内容可以自己执行试一试

* **- S 汇编**
预处理完成后,将生成的.i文件进一步编译为汇编代码
```bash
gcc -S hello_world.i -o hello_world.s
```
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/35FB2D84-56F1-47D7-B283-3D73D23D55F1.png)
⚠️这里已经可以看出text段和堆栈的描述了

* **-c 汇编编译**
生成的汇编代码文件hello_world.s，gas汇编器负责将其编译为目标文件
```bash
gcc -c hello_world.s -o hello_world.o
```
至此汇编编译出来的hello_world.o文件已经不是非专业人员能看懂的了
使用工具[GitHub - sharkdp/hexyl: A command-line hex viewer](https://github.com/sharkdp/hexyl)按16进制查看
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/985F54AB-E038-48AF-8FF4-A0DAC5E728FB.png)

* **-o 链接**
gcc连接器是gas提供的，负责将程序的目标文件与所需的所有附加的目标文件连接起来，最终生成可执行文件。附加的目标文件包括静态连接库和动态连接库。
对于上一小节中生成的hello_word.o，将其与Ｃ标准输入输出库进行连接，最终生成程序hello_world
```bash
gcc hello_world.o -o hello_world
```
最后我们的到就是可执行文件hell_world了
执行结果:
```bash
./hello_world
Hello world!
```

```
.
├── hello_world
├── hello_world.c
├── hello_world.i
├── hello_world.o
└── hello_world.s
```

**编译过程是分为四个阶段进行的，即预处理(也称预编译，Preprocessing)、编译(Compilation)、汇编 (Assembly)和连接(Linking)。**

通过最基础的编译流程我们学习了gcc的几个opetion: *-E -S  -c -o *

接下来看看gcc的其他常用的opetion和它们的作用

* **-C**
在预处理的时候, 不删除注释信息, 一般和-E使用, 便于分析程序。

* **-Wall**
警告选项,打开了所有需要注意的警告信息,比如:
修改hello_world.c代码
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/640AB433-3FC9-478F-8D40-BAF3F240A7CF.png)

```bash
gcc -Wall hello_world.c -o hello_world
hello_world.c:4:9: warning: unused variable 'i' [-Wunused-variable]
    int i;
        ^
1 warning generated.
```
多出了一个警告提示我们变量i未被使用

* **-g** 调试选项,便于使用gnu等工具调试代码

* **-O 优化选项**
对于大函数，优化编译的过程将占用较长时间和相当大的内存。优化得到的程序比没优化的要小。不适用-O选项的目的是减少编译的开销，使编译结果能够调试、语句是独立的。-O2是多优化一些，最常使用。这个选项既增加了编译时间，也提高了生成代码的运行效果。-O0是不优化

* **-llibrary 连接器选项**
连接名为library的库文件。连接器在标准搜索目录中寻找这个库文件，库文件的真名字是"liblibrary.a"。搜索目录除了一些系统标准目录外，还包括用户以“-L”选项指定的路径。一般说来用这个方法找到的文件是库文件——即由obj文件组成的归档文件。连接器处理归档文件的方法是：扫描归档文件，寻找某些成员，这些成员的符号目前已被引用，不过还没被定义。但是，如果连接器找到普通的OBJ文件，而不是库文件，就把这个OBJ文件按平常方式连接进来。指定“-l”选项和指定文件名的唯一区别是：“-l”选项用“lib”和“.a”把library包裹起来，而且搜索一些目录。
```bash
gcc -o webserver -lstd -g -Wall -Wno-pointer-sign webserver.c
```

* **-nostartfile选项**
指不连接系统标准启动文件，而标准库文件仍然正常使用。对于一般应用程序，系统标准启动文件是必须的，但对于Bootloader、内核等，却可用这个选项。

* **-nostdlib选项**
指不连接系统标准启动文件和标准库文件，只把指定的文件传递给连接器。常用于编译内核、Bootloader等程序。

* **-static**
在支持动态连接的系统上阻止连接共享库，在不支持动态连接的系统上，该选项无效。
静态链接程序，换句话说，它不需要在运行时依赖动态库来运行。要实现静态链接，需要系统上存在库的存档 (.a) 版本
```bash
gcc  -o hello hello.c
gcc -static -o hello_static hello.c
```

ls查看生成的hello文件和hello_static文件差别如下：
```bash
-rwxr-xr-x 1 book book  82982014-06-11 16:59 hello
-rwxr-xr-x 1 book book 5791432014-06-11 16:59 hello_static
```

* **-shared**
[Shared libraries with GCC on Linux - Cprogramming.com](https://www.cprogramming.com/tutorial/shared-libraries-linux-gcc.html)
[gcc -fPIC 选项_farmwang的专栏-CSDN博客](https://blog.csdn.net/farmwang/article/details/75451922)
生成一个共享OBJ文件，它可以和其他OBJ文件连接产生可执行文件。
可以将多个文件制作为一个库文件，比如：gcc -shared -o text.so text.o text1.o text2.o text3.o

* **-I** 
添加头文件搜索路径选项

* **-I-**
就是取消-I的功能, 所以一般在 -Idir 之后使用。

* **-L**
制定编译的时候，搜索库的路径。比如你自己的库，可以用它制定目录，不然编译器将只在标准库的目录找。这个dir就是目录的名称。

* **-Dmacro**
相当于 C 语言中的 **#define macro**
　　
* **-Dmacro=defn**
相当于 C 语言中的 **#define macro=defn**
　　
* **-Umacro**
相当于 C 语言中的 **#undef macro**

常用的option都简要的介绍了一遍,还是参考之前编译流程的形式,模拟一些常见的常见的场景实操一把
* 查看子目录 gcc_build_static_library编译并调用静态库
⚠️libmath.a: current ar archive random library

* 查看子目录 gcc_build_dynamic_library编译并调用动态库
⚠️libmath.so: Mach-O 64-bit dynamically linked shared library x86_64

介绍完了gcc,接着介绍make和makefile

如果是一些小项目,用仅仅使用gcc还是能勉强应付的,但是还是显得力不从心

针对于大型项目的开发和编译,就需要使用make和makefile

参考:
[概述 — 跟我一起写Makefile 1.0 文档](https://seisman.github.io/how-to-write-makefile/overview.html)

**Makefile带来的好处就是——“自动化编译”，一旦写好，只需要一个make命令，整个工程完全自动编译，极大的提高了软件开发的效率。 make是一个命令工具，是一个解释makefile中指令的命令工具**

* makefile的规则
在讲述这个makefile之前，还是让我们先来粗略地看一看makefile的规则。
```makefile
target … : prerequisites …
    command
    …
    …
```
**target**
可以是一个object file（目标文件），也可以是一个执行文件，还可以是一个标签（label）。对于标签这种特性，在后续的“伪目标”章节中会有叙述。
**prerequisites**
生成该target所依赖的文件和/或target
**command**
该target要执行的命令（任意的shell命令）
这是一个文件的依赖关系，也就是说，target这一个或多个的目标文件依赖于prerequisites中的文件，其生成规则定义在command中。说白一点就是说:
Prerequisites中如果有一个以上的文件比target文件要新的话，command所定义的命令就会被执行。
这就是makefile的规则，也就是makefile中最核心的内容。

示例代码
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/35270627-B6B7-415D-9534-25D70719DB27.png)
目标edit的前置条件就是:main.o kbd.o command.o display.o insert.o search.o files.o utils.o
各个前置条件如何生成在下面各自描述.当edit的所有前置条件齐备后,执行命令:cc -o edit main.o kbd.o command.o display.o insert.o search.o files.o utils.o
即通过cc将所需的.o文件编译成可执行文件edit
⚠️connad前面必须是tab,不是空格

Clean这种，没有被第一个目标文件直接或间接关联，那么它后面所定义的命令将不会被自动执行，不过，我们可以显示要make执行。即命令—— make clean ，以此来清除所有的目标文件，以便重编译。

* makefile中使用变量
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/1B7E8CC0-D0FC-4C99-B06D-B47143F6D695.png)

* Make自动推导
GNU的make很强大，它可以自动推导文件以及文件依赖关系后面的命令，于是我们就没必要去在每一个 .o 文件后都写上类似的命令，因为，我们的make会自动识别，并自己推导命令。
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/F84571A1-A896-4D35-9AE7-A52C9FB82E89.png)

* Make的include
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/A5154B75-0E5E-48C0-8C73-E29A1DBD83EF.png)

* 文件搜寻
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/EBEF913A-B98F-4E59-88EF-7544ABBF37DB.png)

* 多目标
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/63E33B04-8F9C-4297-99B8-298F96A10DFF.png)

* 静态模式
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/595BE533-15DB-43A7-AFAD-F3A8DAAD98CA.png)
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/03CEF7C4-0C7E-406A-82AF-F0553F26D705.png)
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/8C79F454-675B-442D-AE73-3374BF5DB1E9.png)

* 自动生成依赖性
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/8DDDAEBB-2A36-4323-94AF-85E0B8DEB75B.png)
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/8B31D4E7-7212-4827-BFF1-9F1806EE1EF2.png)

* command的执行
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/03C231DB-22AB-4983-B2FC-9B86B8798A7E.png)

* 嵌套执行make
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/9A1F9D0D-5E9B-4F37-8919-942527B0A5EE.png)
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/65CDF4A4-100B-454F-AB96-E5BA1A4E7C54.png)
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/3DDC3884-5FCA-4428-8EAB-BA00A83F8D33.png)

* 定义命令包
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/79108142-2A74-472E-B42D-8004F1A177DD.png)

* 使用变量
在Makefile中的定义的变量，就像是C_C++语言中的宏一样，他代表了一个文本字串，在Makefile中执行的时候其会自动原模原样地展开在所使用的地方。其与C_C++所不同的是，你可以在Makefile中改变其值。在Makefile中，变量可以使用在“目标”，“依赖目标”， “命令”或是Makefile的其它部分中。

变量在声明时需要给予初值，而在使用时，需要给在变量名前加上 $ 符号，但最好用小括号 () 或是大括号 {} 把变量给包括起来。

![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/69096413-E601-41D3-A780-3B5558FB6FCF.png)
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/E202ECA4-7D78-4CA1-B0E2-47C7D743D923.png)


![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/1E38A117-5571-46C5-BC48-F196EC9DFA14.png)

![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/6116C186-E121-40CE-AAC7-DFDAC18AE43A.png)

![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/287C332B-7C2E-4B50-A1C7-48D77DA4AA0B.png)

![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/833DD087-C6AB-49E6-A657-C2A8AD6ACD4A.png)

![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/BDAD2AA6-53AA-4A2D-ABB7-C55A61FA9879.png)

![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/AB57B6AA-A95B-44AF-B462-857156838768.png)

![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/244476FB-19ED-4ADB-8F7A-93D0C79EE779.png)

* **使用条件判断**
[使用条件判断 — 跟我一起写Makefile 1.0 文档](https://seisman.github.io/how-to-write-makefile/conditionals.html)

* **使用函数**
[使用函数 — 跟我一起写Makefile 1.0 文档](https://seisman.github.io/how-to-write-makefile/functions.html)

* 文件名操作
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/BCE9FD64-2C37-444A-BED6-B2D3808439AF.png)
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/09734FA0-482C-4135-8B7C-59D98805DB2F.png)
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/E5360EB4-BCB2-4DA3-9251-6B32DEBBC050.png)
最常用的就是 $(shell pwd)

* make的运行
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/7C785396-9CD6-401A-ACC4-F135C3B9D7A8.png)
⚠️-t 比较有用

* **隐含规则**
https://seisman.github.io/how-to-write-makefile/implicit_rules.html#
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/AD9EBD4F-221A-451F-9EC6-20DACB4A4821.png)

* 自动化变量
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/48D5F190-9875-4223-AC56-190907CD0431.png)

* make更新函数库文件
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/ED52CD9F-FEF4-48A3-8804-94B1BB10D410.png)

* 合并静态库
[c - Merge multiple .so shared libraries - Stack Overflow](https://stackoverflow.com/questions/915128/merge-multiple-so-shared-libraries)
[linux编程合并多个静态库.a为一个.a](https://www.shuzhiduo.com/A/xl561MY1Jr/)
https://stackoverflow.com/questions/915128/merge-multiple-so-shared-libraries
![](%E4%BB%8Egcc%E5%88%B0make%E5%92%8Cmakfile/CD536F79-41B5-464F-8F19-A8DF3A5199B6.png)
.a静态库更像是一个压缩多个.o文件的压缩包
如果需要继续添加可以解出所有.o文件再重新打包

合并多个动态库,几乎是不可能的,但是可以合并多个静态库为一个动态库

* 编写makefile生成静态库和动态库
https://blog.csdn.net/shaoxiaohu1/article/details/46943417
```makefile
# 1、准备工作，编译方式、目标文件名、依赖库路径的定义。
CC = g++
CFLAGS  := -Wall -O3 -std=c++0x 

# opencv 头文件和lib路径 
OPENCV_INC_ROOT = /usr/local/include/opencv 
OPENCV_LIB_ROOT = /usr/local/lib

OBJS = GenDll.o #.o文件与.cpp文件同名
LIB = libgendll.a # 目标文件名 

OPENCV_INC= -I $(OPENCV_INC_ROOT)

INCLUDE_PATH = $(OPENCV_INC)

LIB_PATH = -L $(OPENCV_LIB_ROOT)

# 依赖的lib名称
OPENCV_LIB = -lopencv_objdetect -lopencv_core -lopencv_highgui -lopencv_imgproc

all : $(LIB)

# 2. 生成.o文件 
%.o : %.cpp
    $(CC) $(CFLAGS) -c $< -o $@ $(INCLUDE_PATH) $(LIB_PATH) $(OPENCV_LIB) 

# 3. 生成静态库文件
$(LIB) : $(OBJS)
    rm -f $@
    ar cr $@ $(OBJS)
    rm -f $(OBJS)

tags :
     ctags -R *

# 4. 删除中间过程生成的文件 
clean:
    rm -f $(OBJS) $(TARGET) $(LIB)
```

```makefile
# 1、准备工作，编译方式、目标文件名、依赖库路径的定义。
CC = g++
CFLAGS  := -Wall -O3 -std=c++0x 

# opencv 头文件和lib路径 
OPENCV_INC_ROOT = /usr/local/include/opencv 
OPENCV_LIB_ROOT = /usr/local/lib

OBJS = GenDll.o #.o文件与.cpp文件同名
LIB = libgendll.so # 目标文件名 

OPENCV_INC= -I $(OPENCV_INC_ROOT)

INCLUDE_PATH = $(OPENCV_INC)

LIB_PATH = -L $(OPENCV_LIB_ROOT)

# 依赖的lib名称
OPENCV_LIB = -lopencv_objdetect -lopencv_core -lopencv_highgui -lopencv_imgproc

all : $(LIB)

# 2. 生成.o文件 
%.o : %.cpp
    $(CC) $(CFLAGS) -fpic -c $< -o $@ $(INCLUDE_PATH) $(LIB_PATH) $(OPENCV_LIB) 

# 3. 生成动态库文件
$(LIB) : $(OBJS)
    rm -f $@
    g++ -shared -o $@ $(OBJS)
    rm -f $(OBJS)

tags :
     ctags -R *

# 4. 删除中间过程生成的文件 
clean:
    rm -f $(OBJS) $(TARGET) $(LIB)
```




