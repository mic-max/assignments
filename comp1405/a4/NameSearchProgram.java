import java.io.*;

public class NameSearchProgram {
	public static final int MAX_NAMES = 90000;
	public static String[] names = new String[MAX_NAMES];
	public static int numNames;

	public static void bubbleSortByLength() {
		byte[] namesLength = new byte[numNames];
		for(int i = 0; i < numNames; i++)
			namesLength[i] = (byte) names[i].length();
		for(int i = 1; i < numNames; i++) {
			boolean flag = true;
			for(int j = 0; j < numNames - i; j++) {
				if(namesLength[j] > namesLength[j + 1]) {
					String temp = names[j];
					names[j] = names[j + 1];
					names[j + 1] = temp;
					byte t = namesLength[j];
					namesLength[j] = namesLength[j + 1];
					namesLength[j + 1] = t;
					flag = false;
				}
			}
			if(flag)
				break;
		}
	}

	public static void bucketSortByLength() {
		String[][] n = new String[12][numNames];
		int[] count = new int[12];
		int sum = 0;
		for(int i = 0; i < numNames; i++) {
			byte t = (byte) (names[i].length() - 2);
			n[t][count[t]++] = names[i];
		}
		for(int i = 0; i < n.length; i++) {
			for(int j = 0; j < count[i]; j++)
				names[sum + j] = n[i][j];
			sum += count[i];
		}
	}

	public static void loadData(String dataFile) {
		try {
			BufferedReader in = new BufferedReader(new FileReader(dataFile));
			String line;
			numNames = 0;
			while((line = in.readLine()) != null)
				names[numNames++] = line;
			in.close();
		} catch (FileNotFoundException e) {
			System.out.println("Error: Cannot open file for reading");
			System.exit(-1);
		} catch (IOException e) {
			System.out.println("Error: Cannot read from file");
			System.exit(-1);
		}
	}

	public static void saveData(String dataFile) {
		try {
			PrintWriter out = new PrintWriter(new FileWriter(dataFile));
			for(int i = 0; i < numNames; i++)
				out.println(names[i]);
			out.close();
		} catch (FileNotFoundException e) {
			System.out.println("Error: Cannot open file for writing");
			System.exit(-1);
		} catch (IOException e) {
			System.out.println("Error: Cannot write to file");
			System.exit(-1);
		}
	}

	public static void main(String [] args) {
		loadData("surnames.txt");
		System.out.println("Bubble Sorting ...");
		long start = System.currentTimeMillis();
		bubbleSortByLength();
		System.out.println("Bubble Sort Took: " + (System.currentTimeMillis() - start) / 1000f + " seconds");
		System.out.println("Writing to file ...");
		saveData("surnamesBubbleSorted.txt");
		System.out.println("Done.");
		loadData("surnames.txt");
		System.out.println("Bucket Sorting ...");
		start = System.currentTimeMillis();
		bucketSortByLength();
		System.out.println("Bucket Sort Took: " + (System.currentTimeMillis() - start) / 1000f + " seconds");
		System.out.println("Writing to file ...");
		saveData("surnamesBucketSorted.txt");
		System.out.println("Done.");
	}
}