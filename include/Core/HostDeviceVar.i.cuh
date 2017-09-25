/**
 * @author Federico Busato                                                  <br>
 *         Univerity of Verona, Dept. of Computer Science                   <br>
 *         federico.busato@univr.it
 * @date September, 2017
 * @version v2
 *
 * @copyright Copyright © 2017 cuStinger. All rights reserved.
 *
 * @license{<blockquote>
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * * Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 * </blockquote>}
 *
 * @file
 */
namespace hornet_alg {

template<typename T>
HostDeviceVar<T>::HostDeviceVar() noexcept {
    cuMalloc(_d_value_ptr, 1);
}

template<typename T>
HostDeviceVar<T>::HostDeviceVar(const T& value) noexcept : _value(value) {
    cuMalloc(_d_value_ptr, 1);
}

template<typename T>
HostDeviceVar<T>::HostDeviceVar(const HostDeviceVar& obj) noexcept :
                                        _value(obj._value),
                                        _d_value_ptr(obj._d_value_ptr),
                                        _is_kernel(true) {
    //cuMemcpyToDeviceAsync(_value, _d_value_ptr);
    //std::cout << "copy" << std::endl;
}
/*
template<typename T>
HostDeviceVar<T>::HostDeviceVar(HostDeviceVar&& obj) noexcept :
                                        _value(obj._value),
                                        _d_value_ptr(obj._d_value_ptr),
                                        _is_kernel(true) {
    cuMemcpyToDeviceAsync(_value, _d_value_ptr);
    obj._first_eval = false;
    std::cout << "move" << std::endl;
}*/

template<typename T>
HostDeviceVar<T>::~HostDeviceVar() noexcept {
    if (!_is_kernel)
        cuFree(_d_value_ptr);
}

/*
template<typename T>
__device__ __forceinline__
T& HostDeviceVar<T>::ref() noexcept {
    return &*_d_value_ptr;
}*/

template<typename T>
__device__ __forceinline__
T* HostDeviceVar<T>::ptr() noexcept {
    return _d_value_ptr;
}

template<typename T>
__host__ __device__ __forceinline__
HostDeviceVar<T>::operator T() noexcept {
#if !defined(__CUDA_ARCH__)
    if (!_first_eval)
        cuMemcpyToHostAsync(_d_value_ptr, _value);
    _first_eval = false;
    return _value;
#else
    return *_d_value_ptr;
#endif
}

template<typename T>
__host__ __device__ __forceinline__
const T& HostDeviceVar<T>::operator=(const T& value) noexcept {
#if defined(__CUDA_ARCH__)
    *_d_value_ptr = value;
#else
    cuMemcpyToDeviceAsync(value, _d_value_ptr);
#endif
    _value = value;
    return value;
}

__host__ __device__ __forceinline__
const T& operator()() const noexcept {
    return _value;
}

__host__ __device__ __forceinline__
T& operator()() noexcept {
    return _value;
}

} // namespace hornet_alg
