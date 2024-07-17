public class StringArrayTest {
    public static List<String> generateStringArray(Integer numStrings) {
        List<String> formatted_strings = new List<String>();
        for (Integer i = 0; i < numStrings; i++) {
            formatted_strings.add('Test ' + i);
        }
        System.debug(formatted_strings);
        return formatted_strings;
    }
}