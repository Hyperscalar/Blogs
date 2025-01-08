---
title: How to Reduce Database Query Load from 717,000 Queries/Second to 14,000 Queries/Second Using Only Local Cache
date: 2024-12-21
categories:
- Caching
tags:
- Performance Engineering
- Computer Architecture
- Distributed Systems
- Practical Experience
mathjax: true
---

> Original Title: Significantly Reducing Database Query Load Using the Spatial Locality of Reference



## Locality of Reference

The locality of reference in programs refers to the tendency of a program to execute a small, localized portion of its code at any given time. Similarly, the memory accessed during execution is limited to a small region of the computer's memory.



The locality of reference can be divided into:

- **Temporal Locality**: Refers to the likelihood that recently accessed data or instructions will be accessed again soon. For example, function parameters or local variables used in a function are likely to be reused shortly.
- **Spatial Locality**: Refers to the tendency that once a particular memory location is accessed, nearby memory locations will be accessed soon after. This is common in loops; for example, if the third element in an array is accessed, the fourth element is likely to be accessed in the next iteration.

<!-- more -->

## Caching

Due to the locality of reference, placing frequently accessed data in faster storage can significantly improve program execution efficiency. This is the essence of caching. Caching works by trading space for time—sacrificing the real-time freshness of data in favor of keeping locally cached historical data to reduce the overhead of heavy operations, such as accessing memory, network I/O, etc., thus improving performance.



## Cache Friendliness

Since the effectiveness of caching relies on the program's locality of reference, determining whether a program is cache-friendly involves measuring its locality of reference strength.



A classic example of cache-friendliness is heapsort, which has a theoretically optimal worst-case time complexity of  $O(nlogn)$, but in practice, it usually performs worse than quicksort, which has a worst-case time complexity of $O(n^2)$. This is because heapsort has poor spatial locality of memory access, leading to bad cache-friendliness.



**Quicksort**

{% asset_img Quicksort-Animation.gif Quicksort Animation, From Wikipedia %}

Quicksort's divide-and-conquer algorithm limits memory access to a localized range, resulting in better spatial locality.



**Heapsort**

{% asset_img Heapsort-Animation.gif Heapsort Animation, From Wikipedia %}

Heapsort, on the other hand, has a "jumping" memory access pattern, leading to poorer spatial locality.



## Leveraging Locality of Reference in Distributed Systems

### Storage Hierarchy in Distributed Systems

{% asset_img Memory-Hierarchy.svg Storage Hierarchy in Distributed Systems %}



### Utilizing Temporal Locality in Distributed Systems

Before exploring how to leverage temporal locality in distributed systems, let's first consider how it is utilized in a single-machine computer architecture.



For example, the Apple M1 processor features an extensive multi-level on-chip cache:

<table>
    <tr>
        <th></th>
        <th>Low Power Core (Icestorm)</th>
        <th>High Performance Core (Firestorm)</th>
    </tr>
    <tr>
        <th>L1 Instruction</th>
        <td>128 KB x 4</td>
        <td>192 KB x 4</td>
    </tr>
    <tr>
        <th>L1 Data</th>
        <td>64 KB x 4</td>
        <td>128 KB x 4</td>
    </tr>
    <tr>
        <th>L2</th>
        <td>4 MB (shared among low-power cores)</td>
        <td>12 MB (shared among high-performance cores)</td>
    </tr>
    <tr>
        <th>SLC</th>
        <td colspan="2" align="center">8MB (shared across the entire chip)</td>
    </tr>
</table>


Key characteristics:

1. **Separation of Instructions and Data**: In L1 cache, instructions and data are kept separate to avoid filling up the cache with data, ensuring high cache hit rates for instructions.
1. **Multi-level Caching**: From L1 to L2 and then to SLC, the speed decreases, and the capacity increases. Stronger locality increases the likelihood of cache hits at the faster levels.
1. **Exclusive and Shared Caching**: L1 is exclusive per core, L2 is shared within a core cluster, and SLC is shared across the entire chip (including CPU, GPU, NPU, etc.).



Let us explore how to apply the above strategies to distributed system clusters:

1. **Separation of code instructions and program data**: Separate configuration data caches from user data caches. Additionally, ensure that caches for different scenarios or purposes are kept as distinct as possible.
1. **Multi-level caching strategy**: Employ a hierarchical caching approach, incorporating both single-machine caches and distributed caches.
1. **Combination of exclusivity and sharing**: Use exclusive local caches on single machines and shared distributed caches across clusters.



By effectively employing these caching strategies, we can maximize the exploitation of temporal locality in programs while balancing the differences among caches in terms of speed, capacity, and cost.



### Utilizing Spatial Locality in Distributed Systems

Before delving into how to leverage spatial locality in distributed systems, let's first understand how spatial locality is utilized at the level of single-machine computer architecture.



As is well known, the smallest unit of addressing in memory (RAM) is a byte. This means that a byte is the atomic unit of memory and cannot be subdivided further. This is also why a boolean type, which only contains a single bit of information, is typically stored in memory as one byte.



Now, are the L1, L2, and other CPU caches also atomic units of bytes?

The answer is both yes and no:

- **Yes**: Because caches are generally transparent to the instruction set, they must adhere to the same byte-addressability as memory. For cache access, the atomic unit is the byte, consistent with memory.
- **No**: When it comes to cache loading, the atomic unit is not a byte but a cache line. For example, as mentioned earlier, the M1 processor has a cache line size of 128 bytes. This means that if a cache miss occurs and data needs to be loaded from memory into the cache, the entire cache line—128 bytes—is loaded, even if the requested data is only a single byte.



So, why doesn’t the cache just load the required data instead of the entire cache line? Doesn’t this lead to waste?

The reasons for this design are roughly as follows:

- The design of cache lines takes full advantage of modern DRAM's burst mode, significantly improving memory throughput and reducing latency. We won't go into further detail here.
- A certain amount of waste is acceptable as long as it improves the overall performance of the system. For instance, CPU branch prediction works on a similar principle.
- The degree of waste actually depends on the program's spatial locality. The more pronounced the spatial locality, the smaller the waste.
- In theory, the larger the cache line, the more performance improvement can be seen in programs with strong spatial locality. Of course, the cache line size is also constrained by various physical factors; it cannot be arbitrarily large, and larger is not necessarily better.



As we can see, the design of cache lines is largely aimed at exploiting spatial locality in programs to improve performance. In other words, this design encourages spatial locality: programs with strong spatial locality will benefit from improved performance under this mechanism, while programs with weak spatial locality will suffer performance penalties, much like how quicksort and heapsort were discussed earlier.



Therefore, the key to utilizing spatial locality is: when loading cache data, we should not only load the data currently needed, but also load some "adjacent" data as well. In other words, **the granularity of cache data loading should be greater than the granularity of cache data querying**.



However, when trying to apply this concept in distributed systems, we face two major challenges:

- **How to define "adjacency"**: In memory, adjacency is easily defined as physically contiguous addresses. But for data in databases, the situation is much more complex. Even within the same table, the definition of "adjacency" may vary depending on the usage scenario.
- **How to determine the minimum data unit for cache loading**: Similar to the cache line size in CPU caches. If this value is too small, it limits the utilization of spatial locality. If it is too large, it puts considerable pressure on cache loading overhead and space utilization.



There is no universal answer to these two problems; they need to be balanced based on the specific context. Below, I will illustrate this with a real-world example.



## Practical Case Study

### Background and Challenges

The project I am responsible for is a no-code development platform aimed at the consumer operations. It uses directed acyclic graphs (DAGs) to model various operational strategies within the consumer operations domain, helping operations teams directly implement systematic and refined operational measures. This platform is referred to as the "Strategy Platform.”



In addition to utilizing the complex directed acyclic graph model, another key feature of the Strategy Platform is the stateful nature of its models. Specifically, the platform records the state information of each user, such as the vertex they occupy in each directed acyclic graph. This statefulness enhances the model’s expressiveness, enabling it to support a wide range of more complex real-world business scenarios.



However, there is no such thing as a free lunch. Storing, writing, and querying these user state data present several challenges:

-  **The volume of data to be stored is enormous**, with an estimated scale of over 1 billion records. This will continue to grow as the platform’s usage and business scale increase.
-  **The volume of data to be written is similarly vast**, with an estimated write throughput (TPS) exceeding 10,000. This will also increase with the platform’s usage and business scale.
-  **The volume of data to be queried is even larger**, with an estimated query throughput (QPS) exceeding 100,000. This will continue to grow with the platform’s usage and business scale



### Mitigation Measures

**Addressing the Issue of Large Data Volumes**

- During the database selection phase, Lindorm (a modified version of HBase by Alibaba Cloud) was chosen to support massive data volumes. Additionally, its table-level and row-level TTL (Time to Live) mechanisms allow for easy automatic cleanup of historical data.
- To reduce costs, a shared cluster was selected, which charges based on actual storage, write, and query usage. However, shared clusters can face "noisy neighbor" issues, which may lead to occasional performance fluctuations. Therefore, fault tolerance measures are necessary.



**Addressing the Issue of High Write Volumes**

- Lindorm (HBase) is based on the LSM Tree data structure, and all write operations are sequential. Whether using SSDs or HDDs, sequential writes are several times faster than random writes, thus offering significant write performance.
- State data is written in batches after undergoing some merging. This reduces the Write Transactions Per Second (TPS) and increases throughput.
- State data pruning: Before writing, the state data is filtered to retain only the states of vertices in the directed acyclic graph that are relied upon by other vertices, rather than storing the states of all vertices involved in the execution. This approach has been proven to significantly reduce the data volume for storage, writing, and querying.
- To address occasional performance fluctuations in the shared cluster, fault tolerance during database writes is achieved by retrying through message queue. Additionally, the timestamp-based multi-version feature in Lindorm is used to handle data consistency issues that may arise from retry-induced write reordering.



**Addressing the Biggest Challenge of High Query Volumes**

The most significant challenge, without a doubt, is handling a large volume of query requests. Relying solely on common caching strategies that focus on temporal locality is not very effective for this problem, for the following reasons:

- In the processing of a single request, repeatedly accessing the same vertex state is rare, so the cache hit rate is expected to be low.
- Introducing a multi-level cache strategy would only distribute part of the query load to stores like Redis, leading to additional costs and increased system dependencies, which may cause a drop in SLA (Service Level Agreement).



As a result, a different approach must be taken, focusing on two ideas:

1. During data writes, we adopt a batching strategy to combine multiple individual write requests into a single batch to reduce TPS and improve throughput. What corresponding strategy can be applied during query processing?
1. Queries are usually user-specific, meaning each request typically involves multiple graph executions, and each graph execution involves several vertices. This creates a clear amplification effect: the query load for the state database = request volume × average number of graphs per request × average number of vertices per graph.

> If Idea 1 goes off course, it could result in a strategy where a single data query request is first blocked, waiting to accumulate a certain number of requests or until a specific time threshold is reached before issuing a batch query. While this could indeed achieve batching, it will undoubtedly increase request latency deterministically, and it’s uncertain how many requests can be accumulated, meaning the cost is guaranteed but the effectiveness is not assured. Additionally, requests aggregated in this way are usually for different users, meaning that their physical distribution in the database will be relatively dispersed. Whether batching these requests for a query improves or harms the query performance is uncertain… at least the index overhead probably won’t be significantly reduced compared to querying a batch of adjacent data.

Ultimately, both approaches lead to the same conclusion: **the granularity of cache data loading should be greater than the granularity of cache data querying**. This mirrors the concept of cache line design in CPU caches, aiming to exploit the spatial locality of state data query requests.



**Table Key Structure and Cache Loading Strategies**

In the Lindorm database, the primary key for the state table (equivalent to the Rowkey in HBase) is composed of: (userId, graphId, vertexId). Additionally, like HBase, Lindorm supports range queries with leftmost prefix matching.



To implement the idea that "the granularity of cache data loading should be greater than the granularity of cache data querying," there are two choices:

1. **Cache Loading Granularity: (userId, graphId)**. Querying the state data for a specific vertex in a graph for a user triggers loading all state data for that user’s vertices in the same graph into the cache.
1. **Cache Loading Granularity: (userId)**. Querying the state data for a specific vertex in a graph for a user triggers loading all state data for that user’s vertices across all graphs into the cache.



The cache query granularity depends on the use case, but the (userId, graphId, vertexId) key structure must remain unchanged.



Here’s a comparison of the various cache loading strategies:

| Cache Loading Granularity   | Data Rows Loaded       | Data Volume Loaded | Load Latency | Spatial Locality | Memory Pressure |
| --------------------------- | ---------------------- | ------------------ | ------------ | ---------------- | --------------- |
| (userId, graphId, vertexId) | One row                | Small              | Low          | None             | Low             |
| (userId, graphId)           | Multiple adjacent rows | Medium             | Medium       | Medium           | Medium          |
| (userId)                    | Multiple adjacent rows | Large              | High         | Strong           | High            |



### Exploring Spatial Locality

During the development phase, it was anticipated that user state queries would become the largest performance bottleneck in the system. As a result, when the platform first went live, the cache loading granularity was directly configured at the level of (userId, graphId) in order to exploit some degree of spatial locality, while avoiding excessive waste and memory pressure. Of course, we could still estimate the query volume the database would face at the (userId, graphId, vertexId) granularity or even without caching, by monitoring the raw query volume for the cache.



After the (userId, graphId) scheme was launched, the following metrics were observed:

| Cache Loading Granularity   | Cache Query Volume | Cache Load Volume | Average Cache Load Time | Amortized Cache Query Time* |
| --------------------------- | ------------------ | ----------------- | ----------------------- | --------------------------- |
| (userId, graphId, vertexId) | 68,000/s           | 68,000/s          | 1 ms                    | 1 ms                        |
| (userId, graphId)           | 68,000/s           | 16,000/s          | 1.5 ms                  | 0.35 ms                     |

*Amortized Cache Query Time*: This refers to distributing the total cache load time across the total cache query volume. In other words: Average Cache Load Time × Cache Load Volume ÷ Cache Query Volume.



From this, we can observe the following from exploiting spatial locality:

- The cache load volume, which corresponds to the database query volume, was reduced to just 23.5% of its original size.
- However, because the amount of data loaded per request increased, the time per load request grew to 150% of the original value, though it remained within an excellent absolute range.
- Furthermore, when we distribute the total load time across the total query volume (averaging the times), the amortized query time dropped to just 35% of the original value. In other words, the overall overhead for querying user state data was reduced by as much as 65%.



### Pushing to the Extreme

After the (userId, graphId) scheme had been running for some time, we observed that the memory pressure and data volumes were much lower than expected and well within acceptable levels.



Thus, we decided to push the scheme to its limit—by setting the cache loading granularity to (userId)!

| Cache Loading Granularity   | Cache Query Volume | Cache Load Volume | Average Cache Load Time | Amortized Cache Query Time |
| --------------------------- | ------------------ | ----------------- | ----------------------- | -------------------------- |
| (userId, graphId, vertexId) | 68,000/s           | 68,000/s          | 1 ms                    | 1 ms                       |
| (userId, graphId)           | 68,000/s           | 16,000/s          | 1.5 ms                  | 0.35 ms                    |
| (userId)                    | 68,000/s           | 2,800/s           | 3.9 ms                  | 0.16 ms                    |



As we pushed spatial locality to its extreme, the following observations were made:

- The cache load volume, or database query volume, was reduced to just 4.12% of the original query volume!
- Due to the larger amount of data loaded per request, the load time per request increased to nearly four times the original, but the absolute value was still within an acceptable range.
- The averaged query time dropped to just 16% of the original value. In other words, the overall overhead for querying user state data was reduced by 84%.



### Long-Term Performance

After a longer period of platform development, the query volume for state cache queries increased significantly. At the same time, thanks to optimizations such as data pruning on the write side, the latest metrics are as follows:

| Time Point | Cache Loading Granularity | Cache Query Volume | Cache Load Volume | Average Cache Load Time | Amortized Cache Query Time* |
| ---------- | ------------------------- | ------------------ | ----------------- | ----------------------- | --------------------------- |
| Launch     | (userId)                  | 68,000/s           | 2,800/s           | 3.9 ms                  | 0.16 ms                     |
| Current    | (userId)                  | 717,000/s          | 14,000/s          | 1.17 ms                 | 0.02 ms                     |



From the latest data, we can observe the following:

- The cache load volume, or database query volume, is now only 1.95% of the query volume!
- The cache hit rate has remained stable at around 97.95%.
- The load time per cache request has decreased to 1.17 ms/request! This reduction is mainly attributed to optimizations on the write side, such as data pruning, which reduced the overall data volume in the database. Consequently, less data needs to be loaded, resulting in a significant reduction in load time.
- The averaged query time has dropped dramatically to just 0.02 ms/request. In other words, the overall overhead for querying user state data has decreased by as much as 98%!



After the substantial increase in query volume, combined with optimizations on the write side, the (userId) scheme has demonstrated even greater potential, thanks to its extensive exploitation of spatial locality.



### Risks

At this point, you may be wondering: what are the trade-offs?

- Could such an aggressive cache loading strategy cause the memory to overflow?
- Is there a risk of having massive data under a single user?
- How is the GC (Garbage Collection) pressure?
- Will the memory requirements be excessively high?



These concerns are indeed valid, and to address them, we have implemented detailed and comprehensive monitoring based on custom Prometheus metrics and our internal monitoring system:

- Local cache usage, query hit rate, query volume, load volume, average load time, load failure rate, eviction volume, etc.;
- Batch write and batch read sizes of the state database tables, used to monitor risks such as excessive data volume under a single user;
- JVM GC performance on every single machine, including: GC frequency per minute, cumulative GC time per minute, heap memory usage, etc.



It is important to note:

- The state cache is only valid for 1 second after loading;
- All individual machines are x86 containers with 4 CPU cores and 8 GiB RAM.



From the monitoring metrics, we can observe:

- The peak utilization of the state cache on a single machine is around 600 items, which is not large and is well below the maximum of 2048 items;
- From the batch query monitoring of the state database table, we can observe that the maximum batch query data volume is around 12 items per batch, and it remains stable over time without any spikes. Additionally, considering the scenario on the strategy platform, it is highly unlikely that a single user would have an excessively large amount of data;
- JVM GC performance on a single machine, using JDK 21 and G1 GC, shows a GC frequency of 2-5 times per minute, with a cumulative GC time of 40-130 milliseconds per minute (not per GC cycle), all of which are Young GC events;
- On a single machine with 4 GiB heap memory, after Young GC, the heap usage can drop to around 20%.



In summary, all the metrics are at a very healthy level.



### Review

In the previous sections, it was mentioned that applying a cache strategy that can exploit spatial locality — specifically, a strategy where the granularity of cache data loading is greater than the granularity of cache data querying — to distributed systems presents two major challenges:

1. How to define "adjacency"?
1. How to determine the granularity of data loaded into the cache, i.e., the "cache line size"?



So, how are these two challenges addressed in the case described above?

- **Defining "adjacency"**: In this case, whether cache loading is done based on the granularity of (userId, graphId) or (userId), it still adheres to the principle of leftmost prefix matching of the database primary key (Rowkey). This means that, on the physical layer, these data items are stored adjacently, which allows for better utilization of the database and underlying hardware characteristics during queries. This reduces index overhead and takes advantage of sequential reads, thus optimizing performance overhead during batch queries and achieving the effect where 1 + 1 < 2.
- **Granularity of cache loading**: Unlike cache lines in CPUs, which face strict physical limitations like transistor count, the constraints in distributed systems are usually much more relaxed. For example, memory size is a much less restrictive factor. Therefore, in this case, we are able to use variable-length granularities, such as (userId, graphId) or even (userId), for cache loading. This allows us to fully exploit spatial locality, which would be difficult to achieve in scenarios with strict physical limitations like those in CPUs.



Of course, this specific case has some unique features. Overall, the distribution of state data is relatively sparse, especially for the pruned state data. In more typical scenarios, we still recommend setting a hard limit on the amount of data to be loaded into the cache. For example, when loading in batches, a maximum of N rows should be loaded. While this may not fully exploit spatial locality to its maximum, it effectively controls memory pressure and is suitable for a broader range of scenarios, such as when the amount of data under a single user exceeds the memory limits. This approach is more akin to the cache line strategy in CPUs.



Additionally, when loading data into the cache, a placeholder empty object must be set for values that do not exist in the database to prevent cache penetration. This anti-penetration effect is also enhanced as the granularity of cache loading increases.
