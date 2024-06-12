int add(int i, int j) { return i + j; }
void main() {
  int i = 10;
  double j = 3.1415;
  int k = i + j;
  double l = i + j;
  std::cout << (k);
  std::cout << (l);
  std::cout << (i + j * k);
  std::cout << ("abc");
  std::cout << (i * (j + k));
  std::cout << ("\x0a");
  std::cout << (123.456) << std::endl;
  std::cout << (add(3, 5));
  std::cout << ("\x0a");
}
