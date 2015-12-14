import java.util.Random;

public class SortingProgram {

	public static void printArray(int[] items) {
		System.out.println("\n----------------------------");
		for(int i = 0; i < items.length; i++)
			System.out.println(items[i]);
		System.out.println("----------------------------\n");
	}

	public static int[] randomArray(int elements, int randomAmp) {
		int[] array = new int[elements];
		Random rand = new Random();
		for(int i = 0; i < array.length; i++)
			array[i] = rand.nextInt(randomAmp);
		return array;
	}

	public static int[] linearSeach(int[] items, int target) {
		int[] result = {-1, 0};
		for(int i = 0; i < items.length; i++) {
			result[1]++;
			if(items[i] == target) {
				result[0] = i;
				return result;
			}
		}
		return result;
	}

	public static int[] binarySeach(int[] items, int target) {
		int[] result = {-1, 0};
		int start = 0;
		int end = items.length - 1;
		boolean found = false;
		while(!found && (start <= end)) {
			int middle = (start + end) / 2;
			result[1]++;
			if(items[middle] == target) {
				result[0] = middle;
				return result;
			}
			if(items[middle] < target)
				start = middle + 1;
			else
				end = middle - 1;
		}
		return result;
	}

	public static boolean isSorted(int[] items) {
		for(int i = 1; i < items.length; i++) {
			if(items[i] < items[i - 1])
				return false;
		}
		return true;
	}

	public static int insertionSort(int[] items) {
		int comparisons = 0;
		for(int i = 1; i < items.length; i++) {
			int key = items[i];
			int j = i - 1;
			comparisons++;
			while(j >= 0 && items[j] > key) {
				items[j + 1] = items[j--];
			}
			items[j + 1] = key;
		}
		return comparisons;
	}

	public static void performanceTable() {
		Random rand = new Random();
		int randomAmp = 1000;
		System.out.println(" N | log(N) | N*log(N) | insert/N*log(N) | lin/N | bin/log(N)");
		for(int i = 512; i <= 65536; i *= 2) {
			int target = rand.nextInt(randomAmp);
			int[] array = randomArray(i, randomAmp);
			int icompares = insertionSort(array);
			int[] br = binarySeach(array, target);
			int[] lr = linearSeach(array, target);
			System.out.println(i + " | " + (Math.log(i) / Math.log(2))+ " | " + i * (Math.log(i) / Math.log(2)) + " | " + icompares / (i * (Math.log(i) / Math.log(2))) + " | " + lr[1] / i + " | " + br[1] / (Math.log(i) / Math.log(2)));
		}
	}

	public static void main(String[] args) {
		int[] array = randomArray(10, 10); // 10 elements from 0 - 9
		printArray(array);
		int comparisons = insertionSort(array);
		System.out.println(comparisons + " comparisons were made by insertionSort");
		printArray(array);
		System.out.println(isSorted(array) + " = array sorted\n");
		performanceTable();
	}
}