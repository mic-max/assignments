/*
	Student Name:		Michael Maxwell
	Student Number:		101006277
	References:			I did not use any reference material in developing this assignment.
*/

public class ProcessedFood extends Food {
	
	public ProcessedFood(String name, int cost, int[] date, int[] bestB4) {
		super(name, cost, date, bestB4);
	}

	public int sellingPrice(int[] date) {
		return (int) Math.round(super.sellingPrice(date) * 1.13);
	}
}