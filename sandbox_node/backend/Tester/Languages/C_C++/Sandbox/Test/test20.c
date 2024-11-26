static long count = 0;

static void infiniteRecursiveMethod(long a) {
	count++;
	infiniteRecursiveMethod(a);
}

int main(){
	infiniteRecursiveMethod(1);
}
