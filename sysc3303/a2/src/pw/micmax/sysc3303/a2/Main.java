package pw.micmax.sysc3303.a2;

public class Main {

	public static void main(String[] args) {
		Table table = new Table();

		Thread producer = new Thread(new Producer(table), "Agent");
		producer.start();
		
		new Thread(new Consumer(producer, table, Ingredient.Bread), "Bread Chef").start();
		new Thread(new Consumer(producer, table, Ingredient.PeanutButter), "PeanutButter Chef").start();
		new Thread(new Consumer(producer, table, Ingredient.Jam), "Jam Chef").start();
	}
}
