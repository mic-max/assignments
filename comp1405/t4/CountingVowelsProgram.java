import java.util.Scanner;

public class CountingVowelsProgram {

	public static int numVowels(String s) {
		int n = 0;
		for(int i = 0; i < s.length(); i++)
			if(s.charAt(i) == 'a' || s.charAt(i) == 'a' || s.charAt(i) == 'e' || s.charAt(i) == 'i' || s.charAt(i) == 'o' || s.charAt(i) == 'u' || s.charAt(i) == 'y')
				n++;
		return n;
	}

	public static void main(String[] args) {
		String input;
		System.out.println("Enter a string and I will count the vowels.");
		while((input = new Scanner(System.in).nextLine()) != "quit")
			System.out.println(numVowels(input));
	}
}