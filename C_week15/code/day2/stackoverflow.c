void stack_overflow(void)
{
	stack_overflow(); // Recursive function - will continue making stack frames infinitely
}

int main(void)
{
	stack_overflow();

	return 0;
}
