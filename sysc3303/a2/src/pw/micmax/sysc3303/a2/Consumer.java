package pw.micmax.sysc3303.a2;

import java.util.List;

public class Consumer implements Runnable {

	private Table table;
	private Thread producer;
	private final Ingredient ingredient;

	public Consumer(Thread producer, Table table, Ingredient ingredient) {
		this.table = table;
		this.ingredient = ingredient;
		this.producer = producer;
	}

	@Override
	public void run() {
		while (producer.isAlive() || !table.isEmpty()) {
			if (!table.isEmpty() && !table.contains(ingredient)) {
				List<Ingredient> items = table.removeAll();
				System.out.println(Thread.currentThread().getName() + " takes " + items);
				try {
					Thread.sleep(500);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
				System.out.println(Thread.currentThread().getName() + " ate their sandwich.");
			}
		}
		System.out.println(Thread.currentThread().getName() + " is full.");
	}

}
