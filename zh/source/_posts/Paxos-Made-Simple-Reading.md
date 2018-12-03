---
title: Paxos Made Simple 翻译及总结
date: 2018-09-27
updated: 2018-09-30
categories:
- 论文
- 分布式
tags:
- 一致性算法
- 翻译
- 总结
mathjax: true
---

# Paxos Made Simple 翻译及总结

## Warm-up / 预热

The Paxos algorithm, when presented in plain English, is very simple.

<p align="right">Paxos Made Simple, by Leslie Lamport</p>

The Fast Paxos algorithm, when presented in plain English, is still quite hard to understand for those like us — people who don't have the brain of Leslie Lamport.

<p align="right">A Simpler Proof for Paxos and Fast Paxos, by Keith Marzullo, Alessandro Mei and Hein Meling</p>

<center style="font-size: 2em;">😂</center>

<!-- more -->

## The Problem / 问题

- Safety requirements for consensus / 一致性算法的基本要求:

  - **1 / 约束1: Only a value that has been proposed may be chosen / 只能通过已经被提出的值**
  - **2 / 约束2: Only a single value is chosen / 只能通过单个值**
  - **3 / 约束3: A process never learns that a value has been chosen unless it actually has been / 只能了解已经被通过的值**

- Roles / 角色

  - Proposers / 议长，发起议案

  - Acceptors / 议员，赞成议案

  - Learners / 听众，了解议案

  > A single process may act as more than one agent / 允许身兼数职

- Asynchronous, non-Byzantine model / 异步，非拜占庭模型:

  - Asynchronous / 异步: Agents operate at arbitrary speed, may fail by stopping, and may restart. Since all agents may fail after a value is chosen and then restart, a solution is impossible unless some information can be remembered by an agent that has failed and restarted. / 代理以任意速度运行，可能失效，也可能重启。由于可能出现在通过一个值以后全部代理都失效，所以代理失效前需要保存一些必要的信息，否则将无法恢复。
  - Non-Byzantine / 非拜占庭: Messages can take arbitrarily long to be delivered, can be duplicated, and can be lost, but they are not corrupted. / 消息可能耗费任意长的时间送达，可能重复，也可能丢失，但是不会出错（保证发送的消息和接收到的消息一致）。

## Choosing a Value / 值的通过

### Single acceptor agent / 单个议员

A proposer sends a proposal to the acceptor, who chooses the first proposed value that it receives. / 议长向议员发送一份议案，议员通过最开始接收到的议案。

> Simple but unsatisfactory, because the failure of the acceptor makes any further progress impossible. / 简单但是还不够好，因为议员一旦失效，整个系统也随之失效。

### Multiple acceptor agents / 多个议员

A proposer sends a proposed value to a set of acceptors. An acceptor may accept the proposed value. The value is chosen when a large enough set of acceptors have accepted it. How large is large enough? To ensure that only a single value is chosen, we can let a large enough set consist of any majority of the agents. Because any two majorities have at least one acceptor in common, this works if an acceptor can accept at most one value. / 一个议长将一份议案发送给一组议员。一个议员可能赞成该议案，也可能不赞成。当足够多的议员赞成了该议案，那么该议案就将通过。具体要多少议员赞成才是足够多？为了保证只有单个议案被通过，我们必须保证这一组议员包含全体议员中的多数议员*，因为任何两组多数议员至少会包含一位共有议员，如果一位议员只能赞成一个提案的话，那么就能保证只有单个议案被通过。

> *Majority / *多数: Majority means that a set is consisted of more than half of all acceptors / 多数表示这一组议员由全体议员的**一半以上**的议员组成。

In the absence of failure or message loss, we want a value to be chosen even if only one value is proposed by a single proposer. / 在没有失效和信息丢失的情况下，如果只有一位议长，并且只提了一份议案，那么这个议案就应该被通过（否则系统将不能正常运行下去）。

- **P1 / 约束 P1: An acceptor must accept the first proposal that it receives. / 一位议员必须赞成其收到的第一份议案。**

But this requirement raises a problem. Several values could be proposed by different proposers at about the same time, leading to a situation in which every acceptor has accepted a value, but no single value is accepted by a majority of them. Even with just two proposed values, if each is accepted by about half the acceptors, failure of a single acceptor could make it impossible to learn which of the values was chosen. / 但是约束 P1 还不够完备。不同的议长可能会同时发起多个不同的议案，可能导致不同的议员赞成了不同的议案，但是没有议案获得了多数议员的赞成。**假设有两个议案，每个都获得了大约半数议员的赞同，如果议员总数为偶数个，系统将直接陷入死锁；如果议员总数为奇数个，那么最终决定权就落在了单个议员的手里，如果这时候该议员失效，那么系统就将陷入死锁。**

> 上面的翻译我综合了自己的理解，可能和原文有些对应不上。

P1 and the requirement that a value is chosen only when it is accepted by a majority of acceptors imply that an acceptor must be allowed to accept more than one proposal. / 约束 P1 和约束*当一份议案被多数议员赞成后才会被通过*隐含了条件*一位议员必须可以赞成不止一份议案*。（反证法）

We keep track of the different proposals that an acceptor may accept by assigning a (natural) number to each proposal, so a proposal consists of a proposal number and a value. To prevent confusion, we require that different proposals have different numbers. / 现在我们给议案分配一个自然数，所以现在一份议案是一个二元组（议案序号，值）。同时，为了唯一确定每一份议案，我们规定每一份议案的序号确定且唯一，并且议案的序号必须满足全序关系（全序关系即集合$X$上的反对称（若 $a \le b$ 且 $b \le a$ 则 $a = b$）的、传递（若 $a \le b$ 且 $b \le c$ 则 $a \le c$）的和完全（$a \le b$ 或 $b \le a$）的二元关系，简而言之，集合内的任意两个元素可以比较大小，计算机中的整型就满足全序关系，而 IEEE 754 定义的浮点数中，由于 $NaN \not\le NaN$，所以 IEEE 754 不满足全序关系）。

A value is chosen when a single proposal with that value has been accepted by a majority of the acceptors. In that case, we say that the proposal (as well as its value) has been chosen. / 当一份包含值 v 的议案被多数议员赞成的时候，我们就说该议案（也包括值 v） 被通过了。

We can allow multiple proposals to be chosen, but we must guarantee that all chosen proposals have the same value. / 现在我们可以通过多个议案了，但是我们必须确保通过的多个议案都包含相同的值，这样才能保证约束2。

- P2 / 约束 P2: If a proposal with value v is chosen, then **every higher-numbered** proposal that is chosen has value v. / 如果一份包含值 v 的议案已被通过，那么**每一份大序号更大的**议案都应该包含值 v。

Since numbers are totally ordered, condition P2 guarantees the crucial safety property that only a single value is chosen. / 由于议案序号满足全序关系，所以约束 P2 能保证约束 2。

To be chosen, a proposal must be accepted by at least one acceptor. / 一份议案要被通过，那么这份议案至少要被一位议员赞成。

So, we can satisfy P2 by satisfying / 所以，我们可以对约束 P2 进行加强：

- P2a / 约束 P2a: If a proposal with value v is chosen, then every higher-numbered proposal accepted by any acceptor has value v. / 如果一份包含值 v 的议案已被通过，那么每一份被任何议员赞成的序号更大的议案也包含值 v。

We still maintain P1 to ensure that some proposal is chosen. / 此时，我们仍然需要保证约束 P1，以确保有议案被通过。

Because communication is asynchronous, a proposal could be chosen with some particular acceptor c never having received any proposal. Suppose a new proposer “wakes up” and issues a higher-numbered proposal with a different value. P1 requires c to accept this proposal, violating P2a. / 但是由于通讯是异步的，可能出现某些特定的议员，比如议员 c 完全没有参与某个议案的情况。然后，议长又发起了一份更大序号的并且包含不同的值的议案，这时，根据约束 P1 议员 c 应该赞成该议案，但是这种情况却违反了约束 P2a。

Maintaining both P1 and P2a requires strengthening P2a to / 所以我们在约束 P2a 的基础上继续增强约束:

- P2b / 约束 P2b: If a proposal with value v is chosen, then every higher-numbered proposal issued by any proposer has value v. / 如果一份包含值 v 的议案已被通过，那么每一份被议长发起的序号更大的议案都包含值 v。

Since a proposal must be issued by a proposer before it can be accepted by an acceptor, P2b implies P2a, which in turn implies P2. / 由于一份议案在被议员赞成之前必须现有议案则发起，所以约束 P2b 蕴含约束 P2a，又因为约束 P2a 蕴含约束 P2，故约束 P2b 也蕴含约束 P2。

To discover how to satisfy P2b, let’s consider how we would prove that it holds. / 约束 P2b 虽然约束足够强，但是难以提出实现方式，所以我们通过证明约束 P2b 成立的方式来进一步加强约束。

We would assume that some proposal with number m and value v is chosen and show that any proposal issued with number n > m also has value v. / 假设一份序号为 m 值为 v 的议案 (m, v) 已经被通过，试证任何已发起的序号为 n 且 n > m 的议案都包含值 v。

We would make the proof easier by using induction on n, so we can prove that proposal number n has value v under the additional assumption that every proposal issued with a number in m . . (n − 1) has value v , where i . . j denotes the set of numbers from i through j . / 为了简化证明过程，我们对 n 使用数学归纳法，这样我们就可以通过附加假设条件每一份以及发起的序号在 m 到 n-1 这个闭区间的议案都包含值 v 来证明序号为 n 的议案包含值 v。

For the proposal numbered m to be chosen, there must be some set C consisting of a majority of acceptors such that every acceptor in C accepted it. / 对于将要被通过的序号为 m 的议案，一定存在一个集合 C 由多数议员构成，并且集合 C 中的所有议员都赞成了该议案。

Combining this with the induction assumption, the hypothesis that m is chosen implies / 再结合刚才的归纳假设，假设 m 已被通过则意味着:

<center>
    Every acceptor in C has accepted a proposal with number in m ..(n − 1), and every proposal with number in m ..(n − 1) accepted by any acceptor has value v. / 集合 C 中的每一位议员都接受了序号在 m 到 n-1 这个闭区间中的某个提议，并且每个序号在 m 到 n-1 这个闭区间中的提议都被包含值 v 的任意一位议员接受了。
</center>

Since any set S consisting of a majority of acceptors contains at least one member of C, we can conclude that a proposal numbered n has value v by ensuring that the following invariant is maintained / 回顾前面对于‘多数’议员的定义，由于任意由多数议员组成的集合 S 和集合 C 之间至少有一位共同议员，那么我们通过保证以下的不变性来得出序号为 n 的议案包含值 v 的结论:

- P2c / 约束 P2c: For any v and n, if a proposal with value v and number n is issued, then there is a set S consisting of a majority of acceptors such that either (a) no acceptor in S has accepted any proposal numbered less than n, or (b) v is the value of the highest-numbered proposal among all proposals numbered less than n accepted by the acceptors in S. / 对于任意的 v 和 n，如果一份值为 v 序号为 n 的议案被发起，那么就存在一个由多数议员构成的集合 S 满足下列条件之一：(a) 集合 S 中没有任何一个议员赞成了任何序号小于 n 的议案；(b) v 是集合 S 中的议员所赞成的所有序号小于 n 的议案中序号最大的那一份议案所包含的值。

> 结合 P2c 的假设和条件 (b) 可以证明 P2c 蕴含了 P2b

To maintain the invariance of P2c, a proposer that wants to issue a proposal numbered n must learn the highest-numbered proposal with number less than n, if any, that has been or will be accepted by each acceptor in some majority of acceptors. / 为了维持约束 P2c 的不变性，当一位议长想发起一份值为 n 的议案之前，如果存在序号小于 n 的的议案的话，他必须先知道其中已经或者将要被多数议员赞成的序号最大的那一份议案。

Learning about proposals already accepted is easy enough; predicting future acceptances is hard. Instead of trying to predict the future, the proposer controls it by extracting a promise that there won’t be any such acceptances. In other words, the proposer requests that the acceptors not accept any more proposals numbered less than n. / 相对于预测将来的议员赞成情况而言，了解已经被议员赞成的议案要简单得多。因此，与其花大力气去预测未来，还不如通过承诺的方式来让议长控制不会有不符合条件的议案赞成情况。换句话说，议长要求议员作出承诺，保证不会再赞成序号小于 n 的议案。

This leads to the following algorithm for issuing proposals. / 这样，我们就得到了发起议案的算法:

1. A proposer chooses a new proposal number n and sends a request to each member of some set of acceptors, asking it to respond with / 一位议长通过一个新的议案序号 n，然后向某个集合（应该是‘多数’议员）的全部议员发起请求，并要求对方回复以下两方面的内容:  

   (a) A promise never again to accept a proposal numbered less than n, and / 要求对方作出承诺，保证不再赞成任何序号小于 n 的议案

   (b) The proposal with the highest number less than n that it has accepted, if any. / 已经赞成的序号小于 n 的议案中，序号最大的那一份议案

   I will call such a request a prepare request with number n.  / 我们将这个过程称作序号 n 的准备请求

2. If the proposer receives the requested responses from a majority of the acceptors, then it can issue a proposal with number n and value v, where v is the value of the highest-numbered proposal among the responses, or is any value selected by the proposer if the responders reported no proposals. / 如果议长收到了多数议员的回复，那么他才能够发起序号为 n 值为 v 的议案，其中 v 是收到的回复中的所有议案里序号最大的那一份议案的值，如果所有回复中都不包含议案，那么 v 则由议长自行指定。

A proposer issues a proposal by sending, to some set of acceptors, a request that the proposal be accepted. (This need not be the same set of acceptors that responded to the initial requests.), Let’s call this an accept request. / 最后，议长将确定好的议案作为请求发送给一组议员（**这里的这一组议员不能和初始阶段的一样**），我们将这个过程称为赞成请求。

What about an acceptor? It can receive two kinds of requests from proposers: prepare requests and accept
requests. An acceptor can ignore any request without compromising safety. / 对于议员而言，其可以接收两种来自议长的请求：准备请求和赞成请求。并且议员会忽略掉那些不满足约束的请求。

So, we need to say only when it is allowed to respond to a request. It can always respond to a prepare request. It can respond to an accept request, accepting the proposal, iff it has not promised not to. In other words / 所以，对于准备请求而言，议员总是可以响应；对于赞成请求而言，当且仅当该议员没有承诺过不赞成该请求时，才响应。换句话说 :

- P1a / 约束 P1a: An acceptor can accept a proposal numbered n iff it has not responded
  to a prepare request having a number greater than n. / 当且仅当一位议员没有响应过序号大于 n 的准备请求时，该议员才能赞成序号为 n 的议案。

Observe that P1a subsumes P1. / 通过观察可以发现约束 P1a 蕴含 P1。

We now have a complete algorithm for choosing a value that satisfies the required safety properties—assuming unique proposal numbers. The final algorithm is obtained by making one small optimization. / 至此，在议案序号唯一的前提下，我们通过推导得到了完整的通过值的算法。最终的算法还可以在此基础上做一些优化。

 Suppose an acceptor receives a prepare request numbered n, but it has already responded to a prepare request numbered greater than n, thereby promising not to accept any new proposal numbered n. There is then no reason for the acceptor to respond to the new prepare request, since it will not accept the proposal numbered n that the proposer wants to issue. So we have the acceptor ignore such a prepare request. We also have it ignore a prepare request for a proposal it has already accepted. 在议员已经响应了一个序号大于 n 的准备请求以后，对于序号为 n 的准备请求就没有必要响应了。同时，对于已经赞成的议案，也没有必要再赞成第二次。

With this optimization, an acceptor needs to remember only the highest-numbered proposal that it has ever accepted and the number of the highest-numbered prepare request to which it has responded. Because P2c must be kept invariant regardless of failures, an acceptor must remember this
information even if it fails and then restarts. / 经过上面的优化以后，议员只需要保存他赞成过的议案中序号最大的那一份和响应过得准备请求中序号最大的那一个就行。因为即使在有失效的情况下我们也必须维护约束 P2c 的不变性，议员就算经历失效或者重启也必须保存上面的信息。

Note that the proposer can always abandon a proposal and forget all about it—as long as it never tries to issue another proposal with the same number. / 值得注意的是，议长总是可以通过不再发起相同序号的新议案的方式来放弃并且遗忘调一份议案。

### Conclude / 总结

Requirements for the algorithm / 算法的约束:

- 1 / 约束1: **Only a value that has been proposed may be chosen / 只能通过已经被提出的值**
- 2 / 约束2: **Only a single value is chosen / 只能通过单个值**
- 3 / 约束3: **A process never learns that a value has been chosen unless it actually has been / 只能了解已经被通过的值**
- P1a / 约束 P1a: **An acceptor can accept a proposal numbered n iff it has not responded to a prepare request having a number greater than n. / 当且仅当一位议员没有响应过序号大于 n 的准备请求时，该议员才能赞成序号为 n 的议案。**
- P2c / 约束 P2c: **For any v and n, if a proposal with value v and number n is issued, then there is a set S consisting of a majority of acceptors such that either (a) no acceptor in S has accepted any proposal numbered less than n, or (b) v is the value of the highest-numbered proposal among all proposals numbered less than n accepted by the acceptors in S. / 对于任意的 v 和 n，如果一份值为 v 序号为 n 的议案被发起，那么就存在一个由多数议员构成的集合 S 满足下列条件之一：(a) 集合 S 中没有任何一个议员赞成了任何序号小于 n 的议案；(b) v 是集合 S 中的议员所赞成的所有序号小于 n 的议案中序号最大的那一份议案所包含的值。**

Properties of the algorithm / 算法的特性:

- Immutability of value / 值的不可变性

  > 要么集群中没有任何议案被提出，这时没有值，一旦有合法的议案被提出，无论后面有多少新的合法的议案被提出，值都是最开始的合法议案中的值。所以称值具有不可变性。

- Minority obeying majority / 少数服从多数

  > 多数定义是至少为全体的一半以上（不包括刚好一半）。

- Prevent the occurrence, Instead of trying to predict the future / 与其预测未来，不如提前预防

  > 要求议员在准备阶段作出承诺。

### The Algorithm / 算法

Putting the actions of the proposer and acceptor together, we see that the algorithm operates in the following two phases. / 将上面的过程整合在一起，我们就得到了最终的算法（通过值部分）:

- Phase 1 / 阶段 1
  - (a) A proposer selects a proposal number n and sends a prepare request with number n to a majority of acceptors. / 一位议长通过一份议案序号 n，并向多数议员发送序号为 n 的准备请求。
  - (b) If an acceptor receives a prepare request with number n greater than that of any prepare request to which it has already responded, then it responds to the request with a promise not to accept any more proposals numbered less than n and with the highest-numbered proposal (if any) that it has accepted. / 如果一位议员接收到的序号为 n 的准备请求的序号大于了任何已经响应的准备请求，那么该议员将响应接收到的序号为 n 的准备请求，作出承诺不再赞成任何序号小于 n 的，并且，如果已经赞成过任何议案的话，顺便返回其中序号最大的那一个（同发起议案算法第1点）。

- Phase 2 / 阶段 2
  - (a) If the proposer receives a response to its prepare requests (numbered n) from a majority of acceptors, then it sends an accept request to each of those acceptors for a proposal numbered n with a value v, where v is the value of the highest-numbered proposal among the responses, or is any value if the responses reported no proposals. / 如果议长收到了多数议员对序号为 n 的准备请求的响应，那么议长就开始向另一组多数议员中的每一位发送序号为 n 值为 v 的议案，其中 v 是收到的响应中的议案中序号最大的那一份议案所包含的值，如果收到的响应中不包含任何议案，那么值 v 由议长任意指定。
  - (b) If an acceptor receives an accept request for a proposal numbered n, it accepts the proposal unless it has already responded to a prepare request having a number greater than n. / 如果一位议员收到序号为 n 的赞成请求，在没有响应过序号大于 n 的准备请求的情况下，该议员将赞成此议案。

A proposer can make multiple proposals, so long as it follows the algorithm for each one. / 议长可以发起多个议案，前提是每一份议案都需要按照算法的流程进行。

It can abandon a proposal in the middle of the protocol at any time. (Correctness is maintained, even though requests and/or responses for the proposal may arrive at their destinations long after the proposal was abandoned.) / 议长可以在任何时候中途废弃议案。（尽管请求或者响应可能在到达目的地之前就已经被废弃，但正确性依然不会受到影响。）

It is probably a good idea to abandon a proposal if some proposer has begun trying to issue a higher-numbered one. / 在某个议长尝试发起一个序号更大的议案时，废弃已有的议案可能是个不错的想法。

Therefore, if an acceptor ignores a prepare or accept request because it has already received a prepare request with a higher number, then it should probably inform the proposer, who should then abandon its proposal. This is a performance optimization that does not affect correctness. / 因此，在一位议员因为已经接收到了更大序号的准备请求后，而忽略当前准备或者赞成请求的时候，该议员应该通知相应的议长废弃当前议案。这在不影响正确性的情况下提高了性能。

## Learning a Chosen Value / 了解已通过的值

To learn that a value has been chosen, a learner must find out that a proposal has been accepted by a majority of acceptors. The obvious algorithm is to have each acceptor, whenever it accepts a proposal, respond to all learners, sending them the proposal. This allows learners to find out about a chosen value as soon as possible, but it requires each acceptor to respond to each learner—a number of responses equal to the product of the number of acceptors and the number of learners. / 为了使听众了解已经被通过的值，听众必须得知道被多数议员赞成的议案的内容。最直观的算法就是，每当议员赞成某个提案时，就通知所有的听众，向他们发送该议案。这样可以保证及时性，但是复杂度太高，达到了 $O(n * m)​$ ，这里 n 是议员个数，m 是听众个数。

The assumption of non-Byzantine failures makes it easy for one learner to find out from another learner that a value has been accepted. We can have the acceptors respond with their acceptances to a distinguished learner, which in turn informs the other learners when a value has been chosen. This approach requires an extra round for all the learners to discover the chosen value. It is also less reliable, since the distinguished learner could fail. But it requires a number of responses equal only to the sum of the number of acceptors and the number of learners. / 回顾前面的非拜占庭假设，我们发现听众可以通过其他听众来准确的了解已被赞成的议案。这样一来，议员就只需要通知某个特定的听众了，剩下的通知工作就可以由听众之间的相互传递来完成。于是，复杂度降低到了 $O(n + m)​$ 。但是，这样的话这位特定的听众就成了单点，会导致可靠性下降很多。

> 复杂度好像还可以更低，如果听众之间用 P2P 通信，应该可以降到 $O(n + log_2 m)​$

More generally, the acceptors could respond with their acceptances to some set of distinguished learners, each of which can then inform all the learners when a value has been chosen. Using a larger set of distinguished learners provides greater reliability at the cost of greater communication complexity. / 介于以上两种策略都有致命的缺陷，一种复杂度太高，另一种可靠性太低，于是我们取两者的折中方案。将第二种方法中的特定听众由一位扩展到一组。以此提高可靠性，但是会以复杂度的提升为代价，需要根据具体场景做权衡。

Because of message loss, a value could be chosen with no learner ever finding out. The learner could ask the acceptors what proposals they have accepted, but failure of an acceptor could make it impossible to know whether or not a majority had accepted a particular proposal. In that case, learners will find out what value is chosen only when a new proposal is chosen. If a learner needs to know whether a value has been chosen, it can have a proposer issue a proposal, using the algorithm described above. / 由于消息有可能会丢失，那么就可能出现一个值被通过了，却没有任何听众了解。听众可以主动询问议员已经赞成了什么议案，但是在极端情况（多数议员之间只有一个共同议员的情况）下，一位议员失效就将导致无法区分该议案是否获得了多数议员的赞成。在这种情况下，听众只能被动的在新的提案被通过的时候才能了解被多数议员赞成的值。如果听众需要主动获得当先被多数议员通过的值，那么他只能通过发起一次新的议案来达到目的，但这也要求该听众同时也是议长（身兼多职）。

## The Progress / 过程

It’s easy to construct a scenario in which two proposers each keep issuing a sequence of proposals with increasing numbers, none of which are ever chosen. Proposer p completes phase 1 for a proposal number n1. Another proposer q then completes phase 1 for a proposal number n2 > n1. Proposer p’s phase 2 accept requests for a proposal numbered n1 are ignored because the acceptors have all promised not to accept any new proposal numbered less than n2. So, proposer p then begins and completes phase 1 for a new proposal number n3 > n2, causing the second phase 2 accept requests of proposer q to be ignored. And so on. / 即使对于上面的算法，仍然可以轻易的构造出两位议长交替发起序号更大的议案，但却无法最终确定的情况，称之为活锁。例如：议长 p 完成了序号为 n1 的阶段 1。另一位议长 q 然后完成了序号 n2 的阶段 1，并且 n2 > n1。议长 p 的阶段 2 的赞成请求会由于议员响应了 议长 q 的 n2 的准备请求（保证不再赞成任何序号小于 n2 的议案）而被忽略。这样，议长 p 就会发起序号为 n3 的阶段 1，且 n3 > n2，于是议长 q 的 序号为 n2 的议案的阶段 2 又会由于议员响应了 议长 p 的 n3 的准备请求（保证不再赞成任何序号小于 n3 的议案）而被忽略，以此循环往复，无休无止。

To guarantee progress, a distinguished proposer must be selected as the only one to try issuing proposals. If the distinguished proposer can communicate successfully with a majority of acceptors, and if it uses a proposal with number greater than any already used, then it will succeed in issuing a proposal that is accepted. By abandoning a proposal and trying again if it learns about some request with a higher proposal number, the distinguished proposer will eventually choose a high enough proposal number.  / 为了保证流程的正常进行，避免活锁的情况，系统中必须只能有一位议长，并且作为唯一的议案发起者，当该议长能够正常的和多数议员通信并且使用大于任何已有议案的序号的议案序号，那么就能保证发起的议案被正常赞成。当该议长了解更大的序号时，废弃当前议案，并发起一份序号更大的议案，以此往复，最终就能发起一份序号足够大的议案，并获得赞成。

> 这样一来，这位集群中唯一的议长就成了单点，为了解决这个问题，需要一种选举算法，在这位议长失效或重启时，及时的选举出替代者，以保证集群正常运作。

> 值得注意的是，为了避免活锁，算法现在只允许集群中有一位议长，而不是最开始的多位议长了，并且增加了议长选举机制（可能是从议员或者听众之间选举，也可能是其他角色）。

If enough of the system (proposer, acceptors, and communication network) is working properly, liveness can therefore be achieved by electing a single distinguished proposer. / 如果有足够多的系统（单个议长，多位议员，以及通信网络）正常运行，集群的健康度就能通过议长的选举来保证。

## Extension / 拓展

- The Part-Time Parliament

  Paxos 算法的最初论文。

  > 论文：The Part-Time Parliament, by Leslie Lamport

- Multi-Paxos

  Paxos 是对一个值达成一致，Multi-Paxos 是运行多个 Paxos 实例来对多个值达成一致，每个 Paxos 实例对不同的值达成一致。

  > 论文：Multi-Paxos: An Implementation and Evaluation, by Hao Du and David J. St. Hilaire

- Fast-Paxos

  Paxos 的进一步工程化，就是 Client 的提案由 Coordinator 进行，Coordinator 存在多个，但只能通过其中被选定 Leader 进行；提案由 Leader 交由 Server (Acceptor) 进行表决，之后 Client 作为 Learner 学习决议的结果。这种方式更多地考虑了 Client / Server 这种通用架构，更清楚地注意到了 Client 既作为 Proposer 又作为 Learner 这一事实。

  > 论文：Fast Paxos, by Leslie Lamport
  >
  > 论文：A Simpler Proof for Paxos and Fast Paxos, by by Keith Marzullo, Alessandro Mei and Hein Meling

- Raft

  Raft is a consensus algorithm that is designed to be easy to understand. It's equivalent to Paxos in fault-tolerance and performance. The difference is that it's decomposed into relatively independent subproblems, and it cleanly addresses all major pieces needed for practical systems. / Raft 算法被设计的更容易理解。在容错和性能方面与 Paxos 算法相当。

  > 论文及实现：[Raft Consensus Algorithm](https://raft.github.io/)
