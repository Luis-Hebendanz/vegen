// RUN: %clang-o3 -march=native -mllvm -filter=kernel %s -o %t && %t

__attribute__((noinline))
void kernel(int n, float *restrict RET, float *restrict aFOO, float b) {
  for (int programIndex = 0; programIndex < n; programIndex++) {
    float a = aFOO[programIndex&0x3];
    float i, j;
    for (i = 0; i < b; ++i) {
      ++a;
      for (j = 0; j < b; ++j) {
        if (a == 3.) break;
        ++a;
      }
      ++a;
    }
    RET[programIndex] = a;
  }
}

int main() {
  int n = 1030;
  float ret[n], a[n];
  for (int i = 0; i < n; i++)
    a[i] = i + 1;

  kernel(n, ret, a, 5.);

  for (int i = 0; i < n; i++) {
    int mod = i % 4;
    if (mod == 0 && ret[i] != 32)
      return 1;
    if (mod == 1 && ret[i] != 32)
      return 1;
    if (mod == 2 && ret[i] != 38)
      return 1;
    if (mod == 3 && ret[i] != 39)
      return 1;
  }
  return 0;
}
