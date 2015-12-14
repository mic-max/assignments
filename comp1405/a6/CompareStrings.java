public class CompareStrings {

	public static boolean match(String x, String y) {
		// both are empty strings
		if(x.length() == 0 && y.length() == 0)
			return true;
		// one of the strings are empty
		if(x.length() == 0) {
			if(y.charAt(0) == '*')
				return match(x, y.substring(1));
			return false;
		}
		if(y.length() == 0) {
			if(x.charAt(0) == '*')
				return match(x.substring(1), y);
			return false;
		}
		// one of the strings begins with a * wildcard
		if(x.charAt(0) == '*' || y.charAt(0) == '*')
			return match(x.substring(1), y) || match(x, y.substring(1)) || match(x.substring(1), y.substring(1));
		// the first characters match or one is a @ wildcard
		if(x.charAt(0) == y.charAt(0) || x.charAt(0) == '@' || y.charAt(0) == '@')
			return match(x.substring(1), y.substring(1));
		return false;
	}

	public static void main(String args[]) {
		String[] s1 = {"hello", "hello", "hello", "hello", "hello", "anyString", "help" , "help", "help", "help", "help" , ""  , ""   , ""   , "A"  , "ABCD", "AB" , "ABCDE", "ABC", ""};
		String[] s2 = {"hello", "h@llo", "h@@@@", "h*"   , "*l*"  , "*"        , "h@@@@", "h*"  , "*l*" , "*l*p", "h@llo", "*" , "***", "@"  , "B"  , "ABDC", "*C" , "A*F"  , "A@D", "*@*"};
		System.out.println("┌───────────────┬───────┐");
		System.out.println("│     Words     │ Match │");
		System.out.println("├───────────────┼───────┤");
		for(int i = 0; i < s1.length; i++)
			System.out.printf("│ %13s │   %c   │%n", s1[i] + " - " + s2[i], match(s1[i], s2[i]) ? '^' : '!');
		System.out.println("└───────────────┴───────┘");
	}
}
