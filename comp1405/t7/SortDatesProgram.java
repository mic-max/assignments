public class SortDatesProgram {
	
	public static void sortByDate(int[][] dates) {
		int[] datesNum = new int[dates.length];
		for(int i = 0; i < datesNum.length; i++)
			datesNum[i] = dates[i][0] + dates[i][1] * 30 + dates[i][2] * 365;

		for(int i = 1; i < dates.length; i++) {
			int key = dates[i];
			int j = i - 1;
			while(j >= 0 && dates[j] > key) {
				dates[j + 1] = dates[j--];
			}
			dates[j + 1] = key;
		}
		return comparisons;
	}

	public static void main(String[] args) {
		int[][] dates = {{1, 1, 1970}, {2, 9, 2015}, {21, 3, 1932}, {29, 2, 1932}};
		sortByDate(dates);
	}
}