import java.util.Scanner;

public class DataTypeByteProgram {
	
	public static void main(String[] args) {
		int bits = 0;
		System.out.print("Enter data type: ");
		String type = new Scanner(System.in).next().toLowerCase();
		switch(type) {
			case "byte":
				bits = 8;
				break;
			case "char":
			case "short":
				bits = 16;
				break;
			case "int":
			case "float":
				 bits = 32;
				break;
			case "long":
			case "double":
				bits = 64;
				break;
		}
		System.out.println("A " + type + " uses " + bits + " bits which is " + bits / 8 + " bytes");
	}
}