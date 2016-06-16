/*
	Student Name:		Michael Maxwell
	Student Number:		101006277
	References:			I did not use any reference material in developing this assignment.
*/

public abstract class Product {
	protected String name;
	protected int cost;
	protected int[] date;

	public Product(String name, int cost, int[] date) {
		this.name = name;
		this.cost = cost;
		this.date = date;
	}

	public static int sellPrice(int cost, int comp, int delta, double p1, double p2, double tax) {
		int sell = cost;
		if(comp >= delta)
			sell = (int) Math.round(sell * p1);
		else
			sell = (int) Math.round(sell * p2);

		return (int) Math.round(sell * tax);
	}

	public static int compDate(int[] a, int[] b) {
		int ad = a[0] + 31 * a[1] + 365 * a[2];
		int bd = b[0] + 31 * b[1] + 365 * b[2];
		return ad - bd;
	}

	public abstract int sellingPrice(int[] date);

	public String getName() { return name; }
	public int getCost() { return cost; }
	public int[] getPurchaseDate() { return date; }
}