/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	 name:			/* function starts here */		\
	 pushl $(num);							\
	 jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
  
TRAPHANDLER_NOEC(th0,0)
TRAPHANDLER_NOEC(th1,1)
TRAPHANDLER_NOEC(th2,2)
TRAPHANDLER_NOEC(th3,3)
TRAPHANDLER_NOEC(th4,4)
TRAPHANDLER_NOEC(th5,5)
TRAPHANDLER_NOEC(th6,6)
TRAPHANDLER_NOEC(th7,7)
TRAPHANDLER(th8,8)
TRAPHANDLER_NOEC(th9,9)
TRAPHANDLER(th10,10)
TRAPHANDLER(th11,11)
TRAPHANDLER(th12,12)
TRAPHANDLER(th13,13)
TRAPHANDLER(th14,14)
TRAPHANDLER_NOEC(th15,15)
TRAPHANDLER_NOEC(th16,16)
TRAPHANDLER(th17,17)
TRAPHANDLER_NOEC(th18,18)
TRAPHANDLER_NOEC(th19,19)
TRAPHANDLER_NOEC(th20,20)
TRAPHANDLER_NOEC(th21,21)
TRAPHANDLER_NOEC(th22,22)
TRAPHANDLER_NOEC(th23,23)
TRAPHANDLER_NOEC(th24,24)
TRAPHANDLER_NOEC(th25,25)
TRAPHANDLER_NOEC(th26,26)
TRAPHANDLER_NOEC(th27,27)
TRAPHANDLER_NOEC(th28,28)
TRAPHANDLER_NOEC(th29,29)
TRAPHANDLER_NOEC(th30,30)
TRAPHANDLER_NOEC(th31,31)
TRAPHANDLER_NOEC(th32,32)
TRAPHANDLER_NOEC(th33,33)
TRAPHANDLER_NOEC(th34,34)
TRAPHANDLER_NOEC(th35,35)
TRAPHANDLER_NOEC(th36,36)
TRAPHANDLER_NOEC(th37,37)
TRAPHANDLER_NOEC(th38,38)
TRAPHANDLER_NOEC(th39,39)
TRAPHANDLER_NOEC(th40,40)
TRAPHANDLER_NOEC(th41,41)
TRAPHANDLER_NOEC(th42,42)
TRAPHANDLER_NOEC(th43,43)
TRAPHANDLER_NOEC(th44,44)
TRAPHANDLER_NOEC(th45,45)
TRAPHANDLER_NOEC(th46,46)
TRAPHANDLER_NOEC(th47,47)
TRAPHANDLER_NOEC(th48,48)

/*
 * Lab 3: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
	pushl %ds
        pushl %es
	pushal
        movw $GD_KD, %ax
	movw %ax, %ds
	movw %ax, %es 
        pushl %esp  /* trap(%esp) */
        call trap

.data
.globl trap_handlers
trap_handlers:
	.long th0
	.long th1
	.long th2
	.long th3
	.long th4
	.long th5
	.long th6
	.long th7
	.long th8
	.long th9
	.long th10
	.long th11
	.long th12
	.long th13
	.long th14
	.long th15
	.long th16
	.long th17
	.long th18
	.long th19
	.long th20
	.long th21
	.long th22
	.long th23
	.long th24
	.long th25
	.long th26
	.long th27
	.long th28
	.long th29
	.long th30
	.long th31
        .long th32
	.long th33
	.long th34
	.long th35
	.long th36
	.long th37
	.long th38
	.long th39
	.long th40
	.long th41
        .long th42
	.long th43
	.long th44
	.long th45
	.long th46
	.long th47
        .long th48
