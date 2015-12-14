import java.util.Random;
import javax.swing.JOptionPane;

public class SearchProgram {

	public static boolean randomNumberList = false;

	public static int[] numberList = {-1,3,4,6,7,8,9,20,34,45,42,55,69,73,82,99};

	public static int largestAmplitude(int[] nums, boolean min) {
		int cur = nums[0];
		for(int i = 1; i < nums.length; i++) {
			if(min) {
				if(cur > nums[i])
					cur = nums[i];
			} else {
				if(cur < nums[i])
					cur = nums[i];
			}
		}
		return cur;
	}

	public static void main(String[] args) {
		if(randomNumberList) {
			numberList = new int[250];
			Random rand = new Random();
			for(int i = 0; i < numberList.length; i++)
				numberList[i] = rand.nextInt(1000) + 1;
		}
		int num = Integer.parseInt(JOptionPane.showInputDialog("Enter a number: "));
		int found = 0;
		for(int i = 0; i < numberList.length; i++) {
			if(num == numberList[i])
				found++;
		}
		JOptionPane.showMessageDialog(null, largestAmplitude(numberList, true) + " is the smallest number.");
		JOptionPane.showMessageDialog(null, largestAmplitude(numberList, false) + " is the largest number.");
		if(found > 0)
			JOptionPane.showMessageDialog(null, "Found your number " + found + " times!");
		else
			JOptionPane.showMessageDialog(null, "Couldn't find your number.");
	}
}