/*
 * Copyright 2014-2023 Amazon.com, Inc. or its affiliates.  All Rights Reserved.
 */

#ifndef NCCL_OFI_MEMCHECK_BUILTIN_H
#define NCCL_OFI_MEMCHECK_BUILTIN_H

#ifdef _cplusplus
extern "C" {
#endif

static inline void nccl_net_ofi_mem_defined(void *data, size_t size)
{
}

static inline void nccl_net_ofi_mem_undefined(void *data, size_t size)
{
}

static inline void nccl_net_ofi_mem_noaccess(void *data, size_t size)
{
}

static inline void nccl_net_ofi_mem_create_mempool(void *handle, void *data, size_t size)
{
}

static inline void nccl_net_ofi_mem_destroy_mempool(void *handle)
{
}

static inline void nccl_net_ofi_mem_mempool_alloc(void *handle, void *data, size_t size)
{
}

static inline void nccl_net_ofi_mem_mempool_free(void *handle, void *data, size_t size)
{
}

#ifdef _cplusplus
} // End extern "C"
#endif

#endif // End NCCL_OFI_MEMCHECK_BUILTIN_H
