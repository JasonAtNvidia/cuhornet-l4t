/**
 * @author Federico Busato                                                  <br>
 *         Univerity of Verona, Dept. of Computer Science                   <br>
 *         federico.busato@univr.it
 * @date April, 2017
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
#pragma once

namespace cu_stinger {

class Edge;
class VertexSet;
class VertexIt;
class EdgeIt;

//==============================================================================

class Vertex {
friend class VertexSet;
public:
    /**
     * @brief Default costructor
     */
    __device__ __forceinline__
    Vertex(id_t index) noexcept;

    /**
     * @brief Out-degree of the vertex
     * @return out-degree of the vertex
     */
    __device__ __forceinline__
    degree_t degree() const noexcept;

    /**
     * @brief  value of a user-defined vertex field
     * @tparam INDEX index of the user-defined vertex field to return
     * @return value of the user-defined vertex field at the index `INDEX`
     *         (type at the index `INDEX` in the `EdgeTypes` list)
     * @remark the method does not compile if the `VertexTypes` list does not
     *         contain atleast `INDEX` fields
     * @details **Example:**
     * @code{.cpp}
     *      Vertex vertex = ...
     *      auto vertex_label = vertex.field<0>();
     * @endcode
     */
    template<int INDEX>
    __device__ __forceinline__
    typename std::tuple_element<INDEX, VertexTypes>::type
    field() const noexcept;

    /**
     * @brief Edge of the vertex
     * @return edge at the index `index`
     * @warning `index` must be in the range \f$0 \le index < degree\f$.
     * The behavior is undefined otherwise.
     */
    __device__ __forceinline__
    Edge edge(off_t index) const noexcept;
private:
    byte_t* _ptrs[NUM_VTYPES];
};

//==============================================================================

class Edge {
    friend class Vertex;
    using     EnableWeight = typename std::conditional<(NUM_ETYPES > 1),
                                                        int, void>::type;
    using EnableTimeStamp1 = typename std::conditional<(NUM_ETYPES > 2),
                                                        int, void>::type;
    using EnableTimeStamp2 = typename std::conditional<(NUM_ETYPES > 3),
                                                        int, void>::type;
public:
    /**
     * @brief destination of the edge
     * @return destination of the edge
     */
    __device__ __forceinline__
    id_t dst() const noexcept;

    /**
     * @brief weight of the edge (if it exists)
     * @return weight of the edge (first `EdgeTypes` type)
     * @remark the method is disabled if the `EdgeTypes` list does not contain
     *         atleast one field
     * @details **Example:**
     * @code{.cpp}
     *      Edge edge = ...
     *      auto edge_weight = edge.weight();
     * @endcode
     */
    template<typename T = EnableWeight>
    __device__ __forceinline__
    typename std::tuple_element<(NUM_ETYPES > 1 ? 1 : 0), edge_t>::type
    weight() const noexcept;

    /**
     * @brief first time stamp of the edge
     * @return first time stamp of the edge (second `EdgeTypes` type)
     * @remark the method is disabled if the `EdgeTypes` list does not contain
     *         atleast two fields
     */
    template<typename T = EnableTimeStamp1>
    __device__ __forceinline__
    typename std::tuple_element<(NUM_VTYPES > 2 ? 2 : 0), vertex_t>::type
    time_stamp1() const noexcept;

    /**
     * @brief second time stamp of the edge
     * @return second time stamp of the edge (third `EdgeTypes` list type)
     * @remark the method is disabled if the `EdgeTypes` list does not contain
     *         atleast three fields
     */
    template<typename T = EnableTimeStamp2>
    __device__ __forceinline__
    typename std::tuple_element<(NUM_VTYPES > 3 ? 3 : 0), vertex_t>::type
    time_stamp2() const noexcept;

    /**
     * @brief  value of a user-defined edge field
     * @tparam INDEX index of the user-defined edge field to return
     * @return value of the user-defined edge field at the index `INDEX`
     *         (type at the index `INDEX` in the `EdgeTypes` list)
     * @remark the method does not compile if the `EdgeTypes` list does not
     *         contain atleast `INDEX` fields
     * @details **Example:**
     * @code{.cpp}
     * Edge edge = ...
     *      auto edge_label = edge.field<0>();
     * @endcode
     */
    template<int INDEX>
    __device__ __forceinline__
    typename std::tuple_element<INDEX, EdgeTypes>::type
    field() const noexcept;

private:
    byte_t* _ptrs[NUM_ETYPES];

    __device__ __forceinline__
    Edge(byte_t* block_ptr, off_t index) noexcept;
};

//==============================================================================

class VertexSet {
public:
    __device__ __forceinline__
    VertexIt begin() const noexcept;

    __device__ __forceinline__
    VertexIt end() const noexcept;
};

//==============================================================================

class VertexIt {

};

//================================================================s==============

class EdgeIt {

};

} // namespace cu_stinger

#include "cuStingerTypes.i.cuh"
