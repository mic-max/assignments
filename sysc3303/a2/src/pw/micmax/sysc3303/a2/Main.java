package pw.micmax.sysc3303.a2;

public class Main {

	public static void main(String[] args) {
		// Create the shared data structure where the Agent will add ingredients and
		// Chefs will remove.
		Table table = new Table();

		Thread producer = new Thread(new Producer(table), "Agent");
		producer.start();

		// Creates and starts Chef threads, one for each ingredient.
		for (Ingredient ingredient : Ingredient.values())
			new Thread(new Consumer(producer, table, ingredient), ingredient.toString() + " Chef").start();
	}
}
