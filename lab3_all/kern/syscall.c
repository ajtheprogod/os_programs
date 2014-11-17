/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
	static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
	user_mem_assert(curenv, (void*)s, len, PTE_W | PTE_U);

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
}

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
	static int
sys_cgetc(void)
{
	return cons_getc();
}

// Returns the current environment's envid.
	static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
}

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
	static int
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if (e == curenv)
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
	env_destroy(e);
	return 0;
}

// Dispatches to the correct kernel function, passing the arguments.
	int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	static void *syscalls[] = {
		[SYS_cputs] &sys_cputs,
		[SYS_cgetc] &sys_cgetc,
		[SYS_getenvid] &sys_getenvid,
		[SYS_env_destroy] &sys_env_destroy,

	};
	uint32_t ret = 0, esp = 0, ebp = 0;

	// return -E_INVAL if the system call number is invalid
	// i.e., if it is not the case that 0 <= syscallno < NSYSCALLS
	if (!(0 <= syscallno && syscallno < NSYSCALLS)) {
		return -E_INVAL;
	}

	// Now we need to call the requested system call, but there is a problem.
	// syscall takes five arguments a1-a5, but the system calls take 0-5 arguments.
	// There is no way to determine the arity of the system call at runtime,
	// and I didn't want to hard-code the arity of each function.
	// So with asm code, we do the following:
	// 1. Push the current stack pointer to the stack.
	// Note that, after this instruction, 4(%esp) == 4 + %esp; and that, if we were to pop to the variable esp, we would have *esp == esp.
	// 2. Push to the stack, in reverse order, the five arguments a1-a5.
	// All functions expect arguments to be pushed in reverse order like this.
	// 3. Call the function at the address stored in syscalls[syscallno].
	// If the arity of this system call is n, the function will refer to the last n arguments that were pushed onto the stack (i.e., the first n of the arguments a1-a5).
	// It won't refer to anything higher on the stack than these arguments,
	// so it doesn't matter that we pushed all five of the arguments a1-a5 despite the fact that the system call probably takes less than five arguments.
	// If the system call has a return value, it will store it in %eax. Store the value of %eax in the variable ret.
	// 4. Pop all of the arguments off of the stack, until...
	// 5. We pop off the base pointer that we pushed in 1. (identifiable by esp == ebp).
	// 6. At this point, the state of the stack is exactly the same as before we started executing our asm code. So we return, with a value of ret.
	asm volatile("push %esp");
	asm volatile("pushl %0" : : "r" (a5));
	asm volatile("pushl %0" : : "r" (a4));
	asm volatile("pushl %0" : : "r" (a3));
	asm volatile("pushl %0" : : "r" (a2));
	asm volatile("pushl %0" : : "r" (a1));
	asm volatile("call *%0" : "=a" (ret) : "r" (syscalls[syscallno]));
	do {
		asm volatile("pop %0" : "=r" (ebp));
		asm volatile("mov %%esp,%0" : "=r" (esp));
	} while (esp != ebp);
	return ret;
}

