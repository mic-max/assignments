public class EvenAndOddProgram {

	public static int[] getEvens(int[] nums) {
		int evens = 0;
		for(int i = 0; i < nums.length; i++) {
			if(nums[i] % 2 == 0)
				evens++;
		}
		int[] even = new int[evens];
		evens = 0;
		for(int i = 0; i < nums.length; i++) {
			if(nums[i] % 2 == 0)
				even[evens++] = nums[i];
		}
		return even;
	}

	public static int[] getOdds(int[] nums) {
		int odds = 0;
		for(int i = 0; i < nums.length; i++) {
			if(nums[i] % 2 != 0)
				odds++;
		}
		int[] odd = new int[odds];
		odds = 0;
		for(int i = 0; i < nums.length; i++) {
			if(nums[i] % 2 != 0)
				odd[odds++] = nums[i];
		}
		return odd;
	}

	public static void main(String[] args) {
		int[] a = {1,2,3,4,5,6,7,8,9,10};
		int[] b = getEvens(a);
		int[] c = getOdds(a);
		System.out.println("Evens:");
		for(int i = 0; i < b.length; i++)
			System.out.println(b[i]);
		System.out.println("\nOdds:");
		for(int i = 0; i < c.length; i++)
			System.out.println(c[i]);
	}
}