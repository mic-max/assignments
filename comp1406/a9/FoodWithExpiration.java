/*
	Student Name:		Michael Maxwell
	Student Number:		101006277
	References:			I did not use any reference material in developing this assignment.
*/

public class FoodWithExpiration extends Food {

	public FoodWithExpiration(String name, int cost, int[] date, int[] bestB4) {
		super(name, cost, date, bestB4);
	}

	public int sellingPrice(int[] date) {
		int comp = compDate(bestB4, date);
		if(comp < 0) 
			return -1;
		else if(comp < 2)
			return (int) Math.round(cost / 2);
		return super.sellingPrice(date);
	}
}