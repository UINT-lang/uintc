#include <bits/stdc++.h>
using namespace std;

namespace UINT {

static int32_t operator""_i32(unsigned long long x) {
    return x;
}

using Int32 = int32_t;
using Char = char;

struct StdIn {
    template <typename T>
    T read() {
        T x;
        cin >> x;
        return x;
    }
};

static StdIn stdin;

static auto& stdout = cout;

}  // namespace UINT
