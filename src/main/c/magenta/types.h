#ifndef MG_TYPES_H_INCLUDED
#define MG_TYPES_H_INCLUDED

typedef char mg_i8;
typedef short mg_i16;
typedef int mg_i32;
typedef long long mg_i64;

typedef float mg_f32;
typedef double mg_f64;

typedef void * mg_address;

#define ASSERT_CONCAT_(name, line) assert_##name##_on_line_##line
#define ASSERT_CONCAT(name, line) ASSERT_CONCAT_(name, line)
#define COMPILE_ASSERT(name, condition) enum { ASSERT_CONCAT(name, __LINE__) = 1/(!!(condition)) };

/*
 * Compile time asserts that the integer types are expected sizes.
 */
COMPILE_ASSERT(i8size,sizeof(mg_i8) == 1)
COMPILE_ASSERT(i16size,sizeof(mg_i16) == 2)
COMPILE_ASSERT(i32size,sizeof(mg_i32) == 4)
COMPILE_ASSERT(i64size,sizeof(mg_i64) == 8)

/*
 * Compile time asserts that the float types are expected sizes.
 */
COMPILE_ASSERT(f32size,sizeof(mg_f32) == 4)
COMPILE_ASSERT(f64size,sizeof(mg_f64) == 8)

COMPILE_ASSERT(i8sign,((mg_i8)-1) == -1)
COMPILE_ASSERT(i16sign,((mg_i16)-1) == -1)
COMPILE_ASSERT(i32sign,((mg_i32)-1) == -1)
COMPILE_ASSERT(i64sign,((mg_i64)-1) == -1)

#endif //MG_TYPES_H_INCLUDED
