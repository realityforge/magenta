#ifndef MAGENTA_H_INCLUDED
#define MAGENTA_H_INCLUDED

#ifdef __GNUC__
#  define LABELS_TO_ADDRESSES_SUPPORTED
#endif

/*
 * A list of dispatch schemes
 */
#define MG_SWITCH_DISPATCH 1
#define MG_DIRECT_DISPATCH 2

/*
 * Default to using a suitable dispatch scheme for platform.
 */
#ifndef MG_DISPATCH_SCHEME 
#  ifdef LABELS_TO_ADDRESSES_SUPPORTED
#    define MG_DISPATCH_SCHEME MG_DIRECT_DISPATCH //Direct with no scheduling
#  else
#    define MG_DISPATCH_SCHEME MG_SWITCH_DISPATCH //Switch based
#  endif
#endif

/*
 * Make sure the dispatch scheme is MG_SWITCH_DISPATCH unless on one of the specially supported platforms
 */
#if !defined(LABELS_TO_ADDRESSES_SUPPORTED) && MG_DISPATCH_SCHEME != MG_SWITCH_DISPATCH
#  error "Switch based dispatch is the only dispatch scheme supported on this platform"
#endif

/*
 * Make sure a valid dispatch scheme was specified
 */
#if !(MG_DISPATCH_SCHEME == MG_SWITCH_DISPATCH) && !(MG_DISPATCH_SCHEME == MG_DIRECT_DISPATCH)
#  error Unknown value of MG_DISPATCH_SCHEME
#endif

#endif //MAGENTA_H_INCLUDED
