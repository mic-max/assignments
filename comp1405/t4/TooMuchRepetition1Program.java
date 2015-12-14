import java.util.Scanner;

public class TooMuchRepetition1Program {
	static final String GREAT = "   _____                    _    _ \n  / ____|                  | |  | |\n | |  __  _ __  ___   __ _ | |_ | |\n | | |_ || '__|/ _ \\ / _` || __|| |\n | |__| || |  |  __/| (_| || |_ |_|\n  \\_____||_|   \\___| \\__,_| \\__|(_)";
	static final String SORRY = "   _____                                   __\n  / ____|                              _  / /\n | (___    ___   _ __  _ __  _   _    (_)| | \n  \\___ \\  / _ \\ | '__|| '__|| | | |      | | \n  ____) || (_) || |   | |   | |_| |    _ | | \n |_____/  \\___/ |_|   |_|    \\__, |   (_)| | \n                              __/ |       \\_\\\n                             |___/           ";

	public static void main(String[] args){
		Scanner sc = new Scanner(System.in);
		char inputChar;
		int inputInt, count = 0, tries = 0;

		System.out.print("Do you want to play a game? [Y/N]");
		inputChar = sc.next().toLowerCase().charAt(0);

		if(inputChar == 'y') {
			inputInt = 3;
			while(inputInt >= 0) {
				System.out.print("Pick a number between 0 and 2 [0,1,2] [-1 to quit]: ");
				if((inputInt = sc.nextInt()) == -1)
					continue;
				tries++;
				if(inputInt == (int) (Math.random() * 3)) {
					System.out.println(GREAT);
					count++;
				} else
					System.out.println(SORRY);
			}
			if(count > tries / 3D)
				System.out.println(GREAT);
			System.out.println("You got " + count + " guess correct! (out of " + tries  + " guesses)");      
		} else
			System.out.println("Bye-bye!");
	} 
}