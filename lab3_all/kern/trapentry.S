#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup). You can declare the function with
 * void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num) \
.text;	\
.globl name;	/* define global symbol for 'name' */	\
.type name, @function;	/* symbol type is function */	\
.align 2;	/* align function definition */	\
name:	/* function starts here */	\
pushl $(num);	\
jmp _alltraps;	\
.data;	/* see the comments for vectors (below) about the layout of the data that is written here */	\
.long (num);	/* writes the trap number to memory */	\
.long name	/* writes the address of the function 'name' to memory */

/* Pass a pre-processor #define'd macro (where the name is the trap name, and the value is the trap number).
 * We use name##_HANDLER as the function name, and the value as the trap num.
 */
#define TRAPHANDLER1(name) TRAPHANDLER(name##_HANDLER, (name))

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num) \
.text;	\
.globl name;	\
.type name, @function;	\
.align 2;	\
name:	\
pushl $0;	\
pushl $(num);	\
jmp _alltraps;	\
.data;	\
.long (num);	\
.long name

#define TRAPHANDLER_NOEC1(name) TRAPHANDLER_NOEC(name##_HANDLER, (name))

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
.data
.globl vectors
/*
 * Whenever TRAPHANDLER is called, two pieces of .long data are written to memory in the vectors data segment.
 * These are the trap number and the address of the trap handler, respectively.
 * So the entries alternate between trap numbers and addresses of trap handlers.
 * If we have 'extern unsigned int vectors[]' and 'int i' with '!(i%2)',
 * then vectors[i] is a trap number, and vectors[i+1] is the address of the trap handler for that trap number.
 * To denote the end of the vectors data segment, T_DEFAULT is the last defined trap, since we can identify it by the fact that it is not a valid trap number.
 * It is important that TRAPHANDLER be called with increasing trap numbers, otherwise initializing the IDT will require more work than is necessary.
 * By the end of this file, 'vectors == { T_DIVIDE, &T_DIVIDE_HANDLER, T_DEBUG, &T_DEBUG_HANDLER, ... , T_DEFAULT, T_DEFAULT_HANDLER }.
 */
vectors:
  TRAPHANDLER_NOEC1(T_DIVIDE)
  TRAPHANDLER_NOEC1(T_DEBUG)
  TRAPHANDLER_NOEC1(T_NMI)
  TRAPHANDLER_NOEC1(T_BRKPT)
  TRAPHANDLER_NOEC1(T_OFLOW)
  TRAPHANDLER_NOEC1(T_BOUND)
  TRAPHANDLER_NOEC1(T_ILLOP)
  TRAPHANDLER_NOEC1(T_DEVICE)
  TRAPHANDLER1(T_DBLFLT)
  TRAPHANDLER1(T_TSS)
  TRAPHANDLER1(T_SEGNP)
  TRAPHANDLER1(T_STACK)
  TRAPHANDLER1(T_GPFLT)
  TRAPHANDLER1(T_PGFLT)
  TRAPHANDLER_NOEC1(T_FPERR)
  TRAPHANDLER1(T_ALIGN)
  TRAPHANDLER_NOEC1(T_MCHK)
  TRAPHANDLER_NOEC1(T_SIMDERR)
  TRAPHANDLER_NOEC(IRQ_TIMER_HANDLER, IRQ_OFFSET+IRQ_TIMER)
  TRAPHANDLER_NOEC(IRQ_KBD_HANDLER, IRQ_OFFSET+IRQ_KBD)
  TRAPHANDLER_NOEC(IRQ_SERIAL_HANDLER, IRQ_OFFSET+IRQ_SERIAL)
  TRAPHANDLER_NOEC(IRQ_SPURIOUS_HANDLER, IRQ_OFFSET+IRQ_SPURIOUS)
  TRAPHANDLER_NOEC(IRQ_IDE_HANDLER, IRQ_OFFSET+IRQ_IDE)
  TRAPHANDLER_NOEC1(T_SYSCALL)
  TRAPHANDLER_NOEC1(T_DEFAULT)



/*
 * Lab 3: Your code here for _alltraps
 */
.globl _alltraps
.type _alltraps, @function
.align 2
_alltraps:
  pushl %ds /* push onto tf_ds */
  pushl %es /* push onto tf_es */
  pushal /* push onto PushRegs */
  movw $GD_KD, %ax
  movw %ax, %ds
  movw %ax, %es
  pushl %esp
  call trap
  addl $4, %esp
