public class BuggyProgram1 {

	public static double avgLength(String[] wordList) {
		int sum = 0;
		for(int i = 0; i < wordList.length; i++)
			sum += wordList[i].length(); 
		return sum / wordList.length;
	}

	public static void main(String[] args) {
		String string_arr[] = new String[10];
		for(int i = 0; i < string_arr.length; i++)
			string_arr[i] = "word" + i;
		System.out.println("The average word length is " + avgLength(string_arr));
	}
}