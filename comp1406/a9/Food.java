/*
	Student Name:		Michael Maxwell
	Student Number:		101006277
	References:			I did not use any reference material in developing this assignment.
*/

public class Food extends Product {

	protected int[] bestB4;
	
	public Food(String name, int cost, int[] date, int[] bestB4) {
		super(name, cost, date);
		this.bestB4 = bestB4;
	}

	public int sellingPrice(int[] date) {
		return Product.sellPrice(cost, compDate(bestB4, date), 0, 2, 1, 1);
	}
}