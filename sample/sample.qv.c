// qv Sample Program No. 1
fun main () {              // Function definition
    var i: int = 10;       // Integers; always signed
    var j: real = 3.14159; // Real numbers; always signed
    var k: char = 'c';     // Character; in ASCII encoding
    var l: int[5];         // 1D array (/vector) with 5 integers
    var m: int[3][4];      // 2D array with 3 rows, each with 4 integers
    var n: char[10] = "Hello, world!"; // 1D arrays with characters are strings
    println(i);            // Function call; print i and a new line character
    i = 20;                // Assign a new value 20 for i
    println(i);
    l = {1, 2, 3, 4, 5};   // Assign a vector with 5 integers 1, 2, 3, 4, 5 in order
    println(l);
    k = '\\';               // Assign a char with new value '\\' (backslash)
    println(k);
    println(n);
    n = "Another string";   /*Test C-style comments*/ n = "Third string";
    println(n);
    ret;                    // Return nothing to terminate the function body
}
