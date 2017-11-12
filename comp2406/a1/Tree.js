/*
	Author: Michael Maxwell
	Student #: 101006277
*/

'use strict';

function Tree(data, left, right) {
	this.data = data;
	this.left = left;
	this.right = right;

	// true if: node has no data element
	this.isEmpty = function() {
		return this && !this.data;
	};

	// true if: node has no children
	this.isLeaf = function() {
		return this && !this.left && !this.right;
	};

	// inserts data into the tree according to BST insertion rules
	this.insert = function(value) {
		if(value.constructor !== Array) {
			var dataArr = []	
			dataArr.push(value);
			value = dataArr;
		}

		for(var i = 0; i < value.length; i++) {
			var node = new Tree(value[i]);
			var cur = this;

			if(this.isEmpty()) {
				this.data = value[i];
				return;
			}

			while(cur) {
				if(value[i] < cur.data) {
					if(cur.left)
						cur = cur.left;
					else {
						cur.left = node;
						break;
					}
				} else if(value[i] > cur.data) {
					if(cur.right)
						cur = cur.right;
					else {
						cur.right = node;
						break;
					}
				} else
					break;
			}
		}
	};

	// removes the subtree rooted at the provided value from the tree iff it is there
	this.remove = function(value) {
		if(this.contains(value)) {
			var cur = this;
			var parent, lastMove;

			while(true) {
				if(value < cur.data) {
					parent = cur;
					cur = cur.left;
					lastMove = 'left';
				} else if(value > cur.data) {
					parent = cur;
					cur = cur.right;
					lastMove = 'right';
				} else {
					if(lastMove === 'left')
						parent.left = undefined;
					else if(lastMove === 'right')
						parent.right = undefined;
					else {
						this.data = undefined;
						this.left = undefined;
						this.right = undefined;
					}
					break;
				}
			}
		}
	};

	// returns true iff the given value is in the tree
	this.contains = function(value) {
		var cur = this;
		var found = false;

		while(!found && cur) {
			if(value < cur.data)
				cur = cur.left;
			else if(value > cur.data)
				cur = cur.right
			else
				found = true;
		}

		return found;
	};

	// returns the largest value in the tree
	this.findLargest = function() {
		var cur = this;

		while(cur.right)
			cur = cur.right;

		return cur.data;
	};

	// returns the smallest value in the tree
	this.findSmallest = function() {
		var cur = this;

		while(cur.left)
			cur = cur.left;

		return cur.data;
	};

	// creates a distinct copy of the tree
	this.copy = function() {
		var left, right;

		if(this.left)
			left = this.left.copy();
		if(this.right)
			right = this.right.copy();

		return new Tree(this.data, left, right);
	};

	// returns a string of all values in the tree
	this.toString = function() {
		var result = [];

		this.treeMap(function(node) {
			result.push(node.data);
		});

		return result.join(', ');
	};

	// applies the given operation (function) to all nodes in the tree
	this.treeMap = function(operation) {
		function inOrder(node) {
			if(node) {
				if(node.left)
					inOrder(node.left);
				operation(node);
				if(node.right)
					inOrder(node.right);
			}
		}

		inOrder(this);
	};
};

// testing method of the format: <function(): output | expected>
function test() {
	console.log("var t = new Tree()");
	var t = new Tree();
	console.log("t.isEmpty(): " + t.isEmpty() + " | true");
	console.log("t.toString(): '" + t.toString() + "' | ''");
	console.log("t.insert(5)");
	t.insert(5);
	console.log("t.isEmpty(): " + t.isEmpty() + " | false");
	console.log("t.isLeaf(): " + t.isLeaf() + " | true");
	console.log("t.toString(): '" + t.toString() + "' | '5'");
	console.log("t.insert(7)");
	t.insert(7);
	console.log("t.toString(): '" + t.toString() + "' | '5, 7'");
	console.log("t.insert(3)");
	t.insert(3);
	console.log("t.toString(): '" + t.toString() + "' | '3, 5, 7'");
	console.log("t.contains(3): " + t.contains(3) + " | true");
	console.log("t.contains(4): " + t.contains(4) + " | false");
	console.log("t.insert([4, 2, 8, 1, 6, 5])");
	t.insert([4, 2, 8, 1, 6, 5]);
	console.log("t.toString(): '" + t.toString() + "' | '1, 2, 3, 4, 5, 6, 7, 8'");
	console.log("t.findSmallest(): '" + t.findSmallest() + "' | '1'");
	console.log("t.findLargest(): '" + t.findLargest() + "' | '8'");
	console.log("t.remove(3)");
	t.remove(3);
	console.log("t.toString(): '" + t.toString() + "' | '5, 6, 7, 8'");
	console.log("var t2 = t.copy");
	var t2 = t.copy();
	console.log("t2.toString(): '" + t2.toString() + "' | '5, 6, 7, 8'");
	console.log("var square = function(node) { node.data *= node.data; }");
	var square = function(node) { node.data *= node.data; }
	console.log("t.treeMap(square)");
	t.treeMap(square);
	console.log("t.toString(): '" + t.toString() + "' | '25, 36, 49, 64'");
	console.log("t2.toString(): '" + t2.toString() + "' | '5, 6, 7, 8'");
}

module.exports.Tree = Tree;
module.exports.test = test;