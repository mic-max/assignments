import java.util.Scanner;

public class ReverseMorseCodeProgram {

	public static char decodeLetter(String s) {
		if(s.charAt(0) == '.') {
			if(s.length() == 1)
				return 'E';
			else if(s.charAt(1) == '.') {
				if(s.length() == 2)
					return 'I';
				else if(s.charAt(2) == '.') {
					if (s.length() == 3)
						return 'S';
					else if(s.charAt(3) == '.')
						return 'H';
					else
						return 'V';
				} else {
					if (s.length() == 3)
						return 'U';
					else
						return 'F';
				}
			} else {
				if(s.length() == 2)
					return 'A';
				else if(s.charAt(2) == '.') {
					if (s.length() == 3)
						return 'R';
					else
						return 'L';
				} else {
					if (s.length() == 3)
						return 'W';
					else if(s.charAt(3) == '.')
						return 'P';
					else
						return 'J';
				}
			}
		} else {
			if(s.length() == 1)
				return 'T';
			else if(s.charAt(1) == '.') {
				if(s.length() == 2)
					return 'N';
				else if(s.charAt(2) == '.') {
					if (s.length() == 3)
						return 'D';
					else if(s.charAt(3) == '.')
						return 'B';
					else
						return 'X';
				} else {
					if (s.length() == 3)
						return 'K';
					else if(s.charAt(3) == '.')
						return 'C';
					else
						return 'Y';
				}
			} else {
				if(s.length() == 2)
					return 'M';
				else if(s.charAt(2) == '.') {
					if (s.length() == 3)
						return 'G';
					else if(s.charAt(3) == '.')
						return 'Z';
					else
						return 'Q';
				} else
					return 'O';
			}
		}
	}

	public static void main(String[] args) {
		String morse, english = "", temp = "";
		System.out.println("Enter morse code sequence:");
		morse = new Scanner(System.in).nextLine() + ' ';
		for(int i = 0; i < morse.length(); i++) {
			if(morse.charAt(i) != ' ')
				temp += morse.charAt(i);
			else {
				if(!temp.isEmpty())
					english += decodeLetter(temp);
				if(morse.length() > i + 3 && morse.charAt(i + 1) == ' ' && morse.charAt(i + 2) == ' ' && morse.charAt(i + 3) == ' ')
					english += ' ';
				temp = "";
			}
		}
		System.out.println(english);
	}
}