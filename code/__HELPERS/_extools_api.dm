//#define EXTOOLS_LOGGING // rust_g is used as a fallback if this is undefined

/proc/extools_log_write()

/proc/extools_finalize_logging()

/proc/auxtools_stack_trace(msg)
	CRASH(msg)

// for debug evaluation
/proc/auxtools_expr_stub()
	CRASH("auxtools not loaded")

GLOBAL_LIST_EMPTY(auxtools_initialized)
#if DM_VERSION >= 515
#define AUXTOOLS_CALL call_ext
#else
#define AUXTOOLS_CALL call
#endif

#define AUXTOOLS_CHECK(LIB)\
	if (!GLOB.auxtools_initialized[LIB]) {\
		if (fexists(LIB)) {\
			var/string = AUXTOOLS_CALL(LIB,"auxtools_init")();\
			if(findtext(string, "SUCCESS")) {\
				GLOB.auxtools_initialized[LIB] = TRUE;\
			} else {\
				CRASH(string);\
			}\
		} else {\
			CRASH("No file named [LIB] found!")\
		}\
	}\

#define AUXTOOLS_SHUTDOWN(LIB)\
	if (GLOB.auxtools_initialized[LIB] && fexists(LIB)){\
		AUXTOOLS_CALL(LIB,"auxtools_shutdown")();\
		GLOB.auxtools_initialized[LIB] = FALSE;\
	}\
