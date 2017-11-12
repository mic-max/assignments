package comp2402a4;

import java.util.*;

public class GeometricTree extends BinaryTree<GeometricTreeNode> {

	public GeometricTree() {
		super (new GeometricTreeNode());
	}
	
	public void inorderDraw() {
		assignLevels();

		Stack<GeometricTreeNode> s = new Stack<GeometricTreeNode>();
		GeometricTreeNode cur = r;
		int minX = 0;
		while(cur != null || !s.empty()) {
			if(cur != null) {
				s.push(cur);
				cur = cur.left;
			} else {
				cur = s.pop();
				cur.position.x = minX++;
				cur = cur.right;
			}
		}
	}
	
	protected void randomX(GeometricTreeNode u, Random r) {
		if (u == null) return;
		u.position.x = r.nextInt(60);
		randomX(u.left, r);
		randomX(u.right, r);
	}
	
	/**
	 * Draw each node so that it's x-coordinate is as small
	 * as possible without intersecting any other node at the same level 
	 * the same as its parent's
	 */
	public void leftistDraw() {
		assignLevels();

		Queue<GeometricTreeNode> q = new LinkedList<GeometricTreeNode>();
		int width = 0;

		q.add(r);
		q.add(null);
		while(!q.isEmpty()) {
			GeometricTreeNode cur = q.remove();
			if(cur == null) {
				width = 0;
				q.add(null);
				if(q.peek() == null)
					break;
				else
					continue;
			}
			cur.position.x = width++;
			if(cur.left != null)
				q.add(cur.left);
			if(cur.right != null)
				q.add(cur.right);
		}

	}
	
	public void balancedDraw() {
		assignLevels();

		Map<GeometricTreeNode, Integer> map = new HashMap<GeometricTreeNode, Integer>();
		
		GeometricTreeNode node = r;
		GeometricTreeNode prev = null;
		int size = 0;

		while(node != null) {
			// go left
			if(prev == node.parent) {
				if(node.left != null) {
					prev = node;
					node = node.left;
					continue;
				} else
					prev = null;
			}
			// go right
			if(prev == node.left) {
				System.out.println(size);
				map.put(node, depth);
				if(node.right != null) {
					prev = node;
					node = node.right;
					continue;
				} else
					prev = null;
			}
			// go up
			if(prev == node.right) {
				prev = node;
				node = node.parent;
			}
		}
	}
		
	protected void assignLevels() {
		assignLevels(r, 0);
	}
	
	protected void assignLevels(GeometricTreeNode u, int i) {
		if (u == null) return;
		u.position.y = i;
		assignLevels(u.left, i+1);
		assignLevels(u.right, i+1);
	}
	
	public static void main(String[] args) {
		GeometricTree t = new GeometricTree();
		galtonWatsonTree(t, 100);
		System.out.println(t);
		t.inorderDraw();
		System.out.println(t);
	}	
}