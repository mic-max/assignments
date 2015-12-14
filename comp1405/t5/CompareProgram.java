import java.util.Arrays;

// assumes arrays of same length
public class CompareProgram {

	public static String[] s1 = {"car", "boat", "dog"};
	public static String[] s2 = {"boat", "car", "dog"};

	public static boolean isSame(String[] s1, String[] s2) {
		for(int i = 0; i < s1.length; i++) {
			if(!s1[i].equals(s2[i]))
				return false;
		}
		return true;
	}

	public static boolean isReverse(String[] s1, String[] s2) {
		for(int i = 0; i < s1.length; i++) {
			if(!s1[i].equals(s2[s1.length - i - 1]))
				return false;
		}
		return true;
	}

	public static boolean isSubSet(String[] s1, String[] s2) {
		Arrays.sort(s1);
		Arrays.sort(s2);
		return isSame(s1, s2);
	}

	public static void main(String[] args) {
		System.out.println(isSame(s1, s2));
		System.out.println(isReverse(s1, s2));
		System.out.println(isSubSet(s1, s2));
	}
}