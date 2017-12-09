##########################
# Low-level benchmarking #
##########################
import Base: llvmcall

"""
    clobber()

Force the compiler to flush pending writes to global memory.
Acts as an effective read/write barrier.
"""
@inline function clobber()
    llvmcall("""
        call void asm sideeffect "", "~{memory}"()
        ret void
    """, Void, Tuple{})
end

"""
    _llvmname(type::Type)

Produce the string name of the llvm equivalent of our Julia code.
Oh my. The preferable way would be to use LLVM.jl to do this for us.
"""
function _llvmname(typ::Type)
    isboxed_ref = Ref{Bool}()
    llvmtyp = ccall(:julia_type_to_llvm, Ptr{Void},
                    (Any, Ptr{Bool}), typ, isboxed_ref)
    name = unsafe_string(
        ccall(:LLVMPrintTypeToString, Cstring, (Ptr{Void},), llvmtyp))
    return (isboxed_ref[], name)
end

"""
    escape(val)

The `escape` function can be used to prevent a value or
expression from being optimized away by the compiler. This function is
intended to add little to no overhead.
See: https://youtu.be/nXaxk27zwlk?t=2441
"""
@generated function escape(val::T) where T
    # If the value is `nothing` then a memory clobber
    # should have the same effect.
    if T == Void
        return :(clobber())
    end
    # We need to get the string representation of the LLVM type to be able to issue a
    # fake call.
    isboxed, name = _llvmname(T)
    if isboxed
        # name will be `jl_value_t*` which we can't use since string based llvmcall can't handle named structs...
        # Ideally we would issue a `bitcast jl_value_t* %0 to i8*`
        Base.warn_once("Trying to escape a boxed value. Don't know how to handle that.")
    else
        ir = """
            call void asm sideeffect "", "X,~{memory}"($name %0)
            ret void
        """
        quote
            llvmcall($ir, Void, Tuple{T}, val)
        end
    end
end