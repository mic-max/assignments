import java.util.Scanner;

public class AddAndDeleteProgram {
	public static String[] words = new String[25];
	public static Scanner  keyboard = new Scanner(System.in);
	public static int currentWords = 0;
	
	public static void printArray() {
		sort();
		System.out.print("[");
		for(int pos = 0; pos < words.length - 1; pos++) {
			System.out.print(words[pos] + ", ");
		}
		if(words.length > 0){
			System.out.print(words[words.length-1]);
		}
		System.out.println("]");
	}

	public static void displayMenu() {
		System.out.println("----------------------------------------------");
		System.out.println("press (d) to delete an element of the array");
		System.out.println("press (a) to add an element to the array ");
		System.out.println("press (q) to quit");
		System.out.println("----------------------------------------------");
	}

	public static void sort() {
		for(int i = 1; i < currentWords - 1; i++) {
			for(int j = 0; j < currentWords - i; j++) {
				if(words[j].length() < words[j + 1].length()) {
					String temp = words[j];
					words[j] = words[j + 1];
					words[j + 1] = temp;
				}
			}
		}
	}

	public static void delete() {
		System.out.println("Which element would you like to delete? [0-" + (words.length - 1) + "]");
		int position = keyboard.nextInt();
		if(words[position] != null)
			currentWords--;
		words[position] = "";
	}

	public static void add() {
		System.out.println("Which word would you like to add to the array?");
		String word = keyboard.next();
		System.out.println("Where would you like to insert it in array? [0-" + (words.length - 1) + "]");
		int position = keyboard.nextInt();
		if(position <= currentWords) {
			String temp = words[position];
			words[position] = word;
			words[++currentWords] = temp;
		}
	}

	public static void main(String[] args) {
		char in = '\0';
		while(in != 'q') {
			printArray();
			displayMenu(); 
			in = keyboard.next().toLowerCase().charAt(0); 
			if(in == 'a')
				add();
			else if(in == 'd')
				delete();
		}
	}
}