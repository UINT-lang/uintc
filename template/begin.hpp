#include <bits/stdc++.h>

namespace UINT {

using Int32 = int32_t;
using Char = char;
using String = std::string;
using Float64 = double;

static Int32 operator""_i32(unsigned long long x) {
    return x;
}
static Float64 operator""_f64(long double x) {
    return x;
}

struct StdIn {
    template <typename T>
    T read() {
        T x;
        std::cin >> x;
        return x;
    }
};

static StdIn stdin;

using std::endl;
using std::operator""s;

template <typename T>
concept LetMutable = !std::is_const_v<T> && !std::is_lvalue_reference_v<T>;

template <typename T>
concept RefMutable = !std::is_const_v<T>;

template <typename T, size_t N>
using Array = std::array<T, N>;

template <typename T>
static auto range(const T& n) {
    return std::views::iota(T(0), n);
}

static auto transform(const auto& f) {
    return std::views::transform([&](const auto& x) {
        if constexpr ( requires { f(x); } ) {
            return f(x);
        } else {
            return f();
        }
    });
}

struct Sorter {
};
static auto sort() {
    return Sorter { };
}
template <typename T>
static auto operator|(std::vector<T>&& v, Sorter) {
    std::sort(v.begin(), v.end());
    return v;
}
static auto operator|(const auto& v, Sorter) {
    return std::vector(v.begin(), v.end()) | Sorter();
}

template <typename F>
struct Foreacher {
    F f;
    template <typename G>
    explicit Foreacher(G&& f) : f(std::forward<G>(f)) { }
};
template <typename G>
static auto foreach(G&& f) {
    return Foreacher<std::decay_t<G>>(std::forward<G>(f));
}
template <typename F>
static auto operator|(const auto& v, Foreacher<F> foreacher) {
    std::for_each(v.begin(), v.end(), [&](const auto& x) {
        if constexpr ( requires { foreacher.f(x); } ) {
            return foreacher.f(x);
        } else {
            return foreacher.f();
        }
    });
}

}  // namespace UINT
