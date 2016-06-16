/*
	Student Name:		Michael Maxwell
	Student Number:		101006277
	References:			I did not use any reference material in developing this assignment.
*/

public class ChildrensClothing extends Clothing {
	
	public ChildrensClothing(String name, int cost, int[] date) {
		super(name, cost, date);
	}

	public int sellingPrice(int[] date) {
		return Product.sellPrice(cost, compDate(date, this.date), 365, 1.1, 1.5, 1.05);
	}
}