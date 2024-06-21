#include <bits/stdc++.h>
using namespace std;

namespace UINT {

static int32_t operator""_i32(unsigned long long x) {
    return x;
}

using Int32 = int32_t;
using Char = char;
using String = string;
using Double = double;

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

template <typename T>
concept LetMutable = !is_const_v<T> && !is_lvalue_reference_v<T>;

template <typename... Args>
decltype(auto) reverse_exclamation(Args&&... args) {
    return std::reverse(forward<Args>(args)...);
};

}  // namespace UINT
