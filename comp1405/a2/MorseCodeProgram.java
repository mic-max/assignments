import java.util.Scanner;

public class MorseCodeProgram {

	public static void main(String[] args) {
		String english, morse = "";
		System.out.println("Enter a sentence of letters & spaces:");
		english = new Scanner(System.in).nextLine().toUpperCase();
		for(int i = 0; i < english.length(); i++) {
			switch(english.charAt(i)) {
				case 'A':
					morse += ".-";
					break;
				case 'B':
					morse += "-...";
					break;
				case 'C':
					morse += "-.-.";
					break;
				case 'D':
					morse += "-..";
					break;
				case 'E':
					morse += ".";
					break;
				case 'F':
					morse += "..-.";
					break;
				case 'G':
					morse += "--.";
					break;
				case 'H':
					morse += "....";
					break;
				case 'I':
					morse += "..";
					break;
				case 'J':
					morse += ".---";
					break;
				case 'K':
					morse += "-.-";
					break;
				case 'L':
					morse += ".-..";
					break;
				case 'M':
					morse += "--";
					break;
				case 'N':
					morse += "-.";
					break;
				case 'O':
					morse += "---";
					break;
				case 'P':
					morse += ".--.";
					break;
				case 'Q':
					morse += "--.-";
					break;
				case 'R':
					morse += ".-.";
					break;
				case 'S':
					morse += "...";
					break;
				case 'T':
					morse += "-";
					break;
				case 'U':
					morse += "..-";
					break;
				case 'V':
					morse += "...-";
					break;
				case 'W':
					morse += ".--";
					break;
				case 'X':
					morse += "-..-";
					break;
				case 'Y':
					morse += "-.--";
					break;
				case 'Z':
					morse += "--..";
					break;
				case ' ':
					morse += "  ";
					break;
				default:
					break;
			}
			morse += " ";
		}
		System.out.println(morse);
	}
}