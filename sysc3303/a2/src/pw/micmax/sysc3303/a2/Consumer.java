package pw.micmax.sysc3303.a2;

import java.util.List;

public class Consumer implements Runnable {

	private Table table;
	private Thread producer;
	private final Ingredient ingredient;

	// Sets up the consumer with an ingredient and references to the producer thread
	// and table.
	public Consumer(Thread producer, Table table, Ingredient ingredient) {
		this.table = table;
		this.ingredient = ingredient;
		this.producer = producer;
	}

	@Override
	public void run() {
		// Condition to exit execution when the producer is dead and there are no
		// ingredients to consume.
		while (producer.isAlive() || !table.isEmpty()) {
			// Only removes table ingredients when the chef needs those exact ones.
			if (table.hasMyIngedients(ingredient)) {
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
		// When they are done print out a little message.
		System.out.println(Thread.currentThread().getName() + " is full.");
	}

}
