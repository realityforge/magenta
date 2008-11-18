#ifndef MAGENTA_H_INCLUDED
#define MAGENTA_H_INCLUDED

#define MG_SWITCH_DISPATCH 1
#define MG_DIRECT_DISPATCH 2

#define MG_DISPATCH_SCHEME 2

#ifndef MG_DISPATCH_SCHEME 
#  ifdef __GNUC__
#    define MG_DISPATCH_SCHEME MG_DIRECT_DISPATCH //Direct with no scheduling
#  else
#    define MG_DISPATCH_SCHEME MG_SWITCH_DISPATCH //Switch based
#  endif
#endif

#if !defined(__GNUC__) && MG_DISPATCH_SCHEME != MG_SWITCH_DISPATCH
#  error "Switch based dispatch is the only dispatch scheme supported under non GNUC compilers"
#endif

#if !(MG_DISPATCH_SCHEME == MG_SWITCH_DISPATCH) && !(MG_DISPATCH_SCHEME == MG_DIRECT_DISPATCH)
#  error Unknown value of MG_DISPATCH_SCHEME
#endif

#endif //MAGENTA_H_INCLUDED
