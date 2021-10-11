# Peyton Walters Independent Study

For my independent study, I have been contributed to a paper on CockroachDB, specifically its new [multi-region primitives](https://www.cockroachlabs.com/docs/stable/multiregion-overview.html). For this paper, I designed, built, and ran performance tests for the [REGIONAL BY ROW](https://www.cockroachlabs.com/docs/stable/multiregion-overview.html#regional-by-row-tables) table type. These tests show how REGIONAL BY ROW differs from the previously-recommended architectures and how to use it appropriately in different contexts.

## Infrastructure

Typically, an internal tool, [roachprod](https://github.com/cockroachdb/cockroach/tree/master/pkg/cmd/roachprod) is used to run Cockroach performance tests. However, since I'm an external contributor, I cannot use this tool. Specifically, there is a [line of config](https://github.com/cockroachdb/cockroach/blob/441809ed57e66fb0c55b5a3504480950be394352/pkg/roachprod/config/config.go#L48) which requires that users have their email `@cockroachlabs.com`.

Due to this limitation, I had to build my own testing infrastructure. I used [Terraform](https://www.terraform.io/) to create the virtual machines for Cockroach to run on and [Ansible](https://www.ansible.com/) to install and configure Cockroach.

### Terraform

All my terraform is in the `tf/` directory. In it, I have two modules:

- `roachcluster` - This module spins up 3 virtual machines in a specified region for running the database. It also spins up one "observer" node from which to run the tests.
- `inventory` - This module takes in IPs of database machines and observers. It then formats out an Ansible inventory file so that Ansible automatically knows which nodes to SSH into.

Then, in `main.tf`, I spin up one roachcluster per-region (`us-east1`, `eu-west2`, `asia-northeast1`) and feed the output of each module into the `inventory` module.

Now, by running `terraform apply`, I have the cockroach topology created, ready for Ansible to take over.

### Ansible

After Terraform finishes, I run my Ansible playbook with `ansible-playbook -u roachadmin bootstrap/main.yml`. This does a few things:

All nodes:

- Copies the `cockroach` binary into `$PATH`.

Database nodes:

- Templates out a service file specifying what region the VM is in and connect IPs for each of the other nodes
- Starts the `cockroach` service on each node

After the successful Ansible run, all nodes have Cockroach running, and I can connect to run my tests!

## Performance Tests

As previously mentioned, these tests are all targeting the `REGIONAL BY ROW` table type. This table type allows users to define a new column, `crdb_region`. Inside this column, users can specify which region they wish for the row to reside in, and the row will be automatically homed to that region. Previously, users had to [manually partition](https://www.cockroachlabs.com/blog/regional-by-row/#how-to-achieve-row-level-data-homing-before-v211) these tables. This operation was exteremely high-complexity, and it didn't guarantee global uniqueness on primary keys like REGIONAL BY ROW does.

Each of the following tests seeks to show how REGIONAL BY ROW performs on different interesting workloads. Each of these tests are run using the benchmark [YCSB](https://github.com/brianfrankcooper/YCSB).

### Simple Reads and Updates

For this test, I ran a simple version of YCSB with only reads and updates. The expected performance characteristics are as follows:

- Baseline - This is a run of the benchmarks on the old manually-partitioned table type. This should show good performance since manual parititioning requires the user to specify extra data about row locality. This extra data allows the Cockroach optimizer to make slightly more efficient queries, but it requires a high operational burden on behalf of the user.
- Default - This is a run of the benchmarks on a standard REGIONAL BY ROW table. This should show good performance but slightly worse than Baseline since it will sometimes have to reach out to all regions to find a remote row instead of only reaching out to one.
- Rehoming - This is a default REGIONAL BY ROW table with auto-rehoming enabled. Rehoming will rehome a row to a new region whenever the row receives an UPDATE. For example, if a row starts in `us-east1` but receives an UPDATE from `us-west1`, it will be rehomed to `us-west1`.

Sidenote: I wrote the [rehoming functionality](https://github.com/cockroachdb/cockroach/pull/69381)!

#### Resulting Graph

The left side of each plot are read latencies, and the right sides are update latencies.

![](/images/rbr-1.png)

### Inserts

For this test, I ran a version of YCSB with reads and inserts. The expected performance characteristics are as follows:

- Baseline - This should have the best performance since with manually-partitioned tables, a primary key can only insert into one region. This means that no global uniqueness checks are required.
- Computed - This should have a performance similar to Baseline since the `crdb_region` column is computed based off other columns. This means that the optimizer does not need to perform global uniqueness checks - it deterministically knows which region to insert into.
- Default - This should have the worst performance. Without `crdb_region` being computed, the optimizer must reach out to all regions to make sure there is no primary key integrity violation.

#### I found a bug!

While running the `Default` tests, we noticed that inserts were taking on the order of 10ms. As previously mentioned, in the Default case, the optimizer should have to perform a global uniqueness check, something that's impossible to do in <100ms (the speed of light is not fast enough!).

After lots of investigation, I [documented some weird-looking behavior](https://gist.github.com/pawalt/43955a83da578ff0a045fd40f59dce8a) where a user could insert two identical primary keys into the same table.

After more investigation, we determined that this was a real bug that impacted the most recent release. Subsequently, [an issue](https://github.com/cockroachdb/cockroach/issues/73024) was opened to track the bug. After a while, a fix was released and a [technical advisory](https://www.cockroachlabs.com/docs/advisories/a73024) was issued.

#### Resulting Graph

The left side of each plot are read latencies, and the right sides are insert latencies.

![](/images/rbr-2.png)

### Rehoming

As mentioned previously, auto-rehoming enables rows to be rehomed to their target regions when they receive an UPDATE. For low-contention rows, this is not a problem since rows will not be moved around much. For high-contention rows, however, they will be constantly thrashed around, never finding a destination to sit at. This will degrade performance since the rehoming from UPDATE never actually helps improve future query performance.

For this experiment, we run rehoming on differing levels of contention to show how decreasing contention improves query performance.

#### Resulting Graph

The left side of each plot are read latencies, and the right sides are update latencies.

![](/images/rbr-3.png)

## Conclusion

This independent study gave me a great chance to learn more about distributed databases, and I got to make a real impact on this paper! The paper is in this repo under the file `sigmod2022.pdf`. Check out the REGIONAL BY ROW evaluation section for my contributions.

I also got to find a bug in production, which is always a very cool experience. I really enjoyed the digging to find the bug, and I'm happy to have helped out some end users.
