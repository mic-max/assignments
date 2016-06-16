// Student Name:	Michael Maxwell
// Student Number:	101006277
// References:		I did not use any reference material in developing this assignment.

import java.util.ArrayList;

public class BinaryTree extends AbstractBinaryTree {

	public int size() {
		return getNumbers().size();
	}

	private int depthR(Node n, Node a, int i) {
		if(a == null)
			return 0;
		if(a.getData().equals(n.getData()))
			return i + 1;

		return depthR(n, a.getLeft(), i + 1) + depthR(n, a.getRight(), i + 1);
	}

	public int depth(Node n) {
		return depthR(n, root, 0) - 1;
	}

	private boolean findR(Integer i, Node n) {
		if(n == null)
			return false;
		return n.getData().equals(i) || findR(i, n.getLeft()) || findR(i, n.getRight());
	}

	public boolean find(Integer i) {
		return findR(i, root);
	}

	private void getNumbersR(ArrayList<Integer> a, Node n) {
		if(n == null)
			return;
		a.add(n.getData());
		getNumbersR(a, n.getLeft());
		getNumbersR(a, n.getRight());
	}

	public ArrayList<Integer> getNumbers() {
		ArrayList<Integer> a = new ArrayList<Integer>();
		getNumbersR(a, root);
		return a;
	}

	public void addLeaf(Integer i) {
		Node n = root;
		while(n.getLeft() != null)
			n = n.getLeft();
		n.setLeft(new Node(i));
	}

	private boolean isLeaf(Node n) {
		return n.getLeft() == null && n.getRight() == null;
	}

	private Node removeLeafR(Node n, boolean leafRemoved) {
		if(n == null || isLeaf(n))
			root = null;

		if(!leafRemoved) {
			if(n.getLeft() != null && isLeaf(n.getLeft())) {
				Node leaf = new Node(n.getLeft().getData());
				n.setLeft(null);
				leafRemoved = true;
				return leaf;
			}

			if(n.getRight() != null && isLeaf(n.getRight())) {
				Node leaf = new Node(n.getRight().getData());
				n.setRight(null);
				leafRemoved = true;
				return leaf;
			}

			if(n.getLeft() != null)
				return removeLeafR(n.getLeft(), leafRemoved);
			if(n.getRight() != null)
				return removeLeafR(n.getRight(), leafRemoved);
		}
		return null;
		/* Removes all leaves
		if(n == null || n.getLeft() == null && n.getRight() == null) {
			return null;
		n.setLeft(removeLeafR(n.getLeft(), leafRemoved));
		n.setRight(removeLeafR(n.getRight(), leafRemoved));
		return n;
		*/
	}

	public Node removeLeaf() {
		return removeLeafR(root, false);
	}

	public static BinaryTree create() {
		BinaryTree b = new BinaryTree();
		b.root = new Node(12,
			new Node(10,
				new Node(30,
					null,
					new Node(29,
						null,
						new Node(51,
							new Node(61),
							new Node(72)
						)
					)
				),
				null
			),
			new Node(40,
				new Node(31,
					new Node(42),
					new Node(34,
						new Node(61,
							new Node(66),
							new Node(73)
						),
						null
					)
				),
				new Node(32,
					null,
					new Node(2,
						new Node(3,
							null,
							new Node(74,
								new Node(5),
								null
							)
						),
						null
					)
				)
			)
		);
		return b;
	}
}