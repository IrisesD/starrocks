[sql]
select
    l_returnflag,
    l_linestatus,
    sum(l_quantity) as sum_qty,
    sum(l_extendedprice) as sum_base_price,
    sum(l_extendedprice * (1 - l_discount)) as sum_disc_price,
    sum(l_extendedprice * (1 - l_discount) * (1 + l_tax)) as sum_charge,
    avg(l_quantity) as avg_qty,
    avg(l_extendedprice) as avg_price,
    avg(l_discount) as avg_disc,
    count(*) as count_order
from
    lineitem
where
    l_shipdate <= date '1998-12-01'
group by
    l_returnflag,
    l_linestatus
order by
    l_returnflag,
    l_linestatus ;
[scheduler]
PLAN FRAGMENT 0(F02)
  DOP: 16
  INSTANCES
    INSTANCE(0-F02#0)
      BE: 10001

PLAN FRAGMENT 1(F01)
  DOP: 16
  INSTANCES
    INSTANCE(1-F01#0)
      DESTINATIONS: 0-F02#0
      BE: 10003
    INSTANCE(2-F01#1)
      DESTINATIONS: 0-F02#0
      BE: 10002
    INSTANCE(3-F01#2)
      DESTINATIONS: 0-F02#0
      BE: 10001

PLAN FRAGMENT 2(F00)
  DOP: 16
  INSTANCES
    INSTANCE(4-F00#0)
      DESTINATIONS: 1-F01#0,2-F01#1,3-F01#2
      BE: 10001
      SCAN RANGES
        0:HdfsScanNode
          1. <PLACEHOLDER>
    INSTANCE(5-F00#1)
      DESTINATIONS: 1-F01#0,2-F01#1,3-F01#2
      BE: 10002
      SCAN RANGES
        0:HdfsScanNode
          1. <PLACEHOLDER>
    INSTANCE(6-F00#2)
      DESTINATIONS: 1-F01#0,2-F01#1,3-F01#2
      BE: 10003
      SCAN RANGES
        0:HdfsScanNode
          1. <PLACEHOLDER>

[fragment]
PLAN FRAGMENT 0
 OUTPUT EXPRS:9: l_returnflag | 10: l_linestatus | 19: sum | 20: sum | 21: sum | 22: sum | 23: avg | 24: avg | 25: avg | 26: count
  PARTITION: UNPARTITIONED

  RESULT SINK

  6:MERGING-EXCHANGE

PLAN FRAGMENT 1
 OUTPUT EXPRS:
  PARTITION: HASH_PARTITIONED: 9: l_returnflag, 10: l_linestatus

  STREAM DATA SINK
    EXCHANGE ID: 06
    UNPARTITIONED

  5:SORT
  |  order by: <slot 9> 9: l_returnflag ASC, <slot 10> 10: l_linestatus ASC
  |  offset: 0
  |  
  4:AGGREGATE (merge finalize)
  |  output: sum(19: sum), sum(20: sum), sum(21: sum), sum(22: sum), avg(23: avg), avg(24: avg), avg(25: avg), count(26: count)
  |  group by: 9: l_returnflag, 10: l_linestatus
  |  
  3:EXCHANGE

PLAN FRAGMENT 2
 OUTPUT EXPRS:
  PARTITION: RANDOM

  STREAM DATA SINK
    EXCHANGE ID: 03
    HASH_PARTITIONED: 9: l_returnflag, 10: l_linestatus

  2:AGGREGATE (update serialize)
  |  STREAMING
  |  output: sum(5: l_quantity), sum(6: l_extendedprice), sum(17: expr), sum(18: expr), avg(5: l_quantity), avg(6: l_extendedprice), avg(7: l_discount), count(*)
  |  group by: 9: l_returnflag, 10: l_linestatus
  |  
  1:Project
  |  <slot 5> : 5: l_quantity
  |  <slot 6> : 6: l_extendedprice
  |  <slot 7> : 7: l_discount
  |  <slot 9> : 9: l_returnflag
  |  <slot 10> : 10: l_linestatus
  |  <slot 17> : 31: multiply
  |  <slot 18> : 31: multiply * CAST(1 + CAST(8: l_tax AS DECIMAL64(16,2)) AS DECIMAL128(16,2))
  |  common expressions:
  |  <slot 27> : CAST(6: l_extendedprice AS DECIMAL128(15,2))
  |  <slot 28> : CAST(7: l_discount AS DECIMAL64(16,2))
  |  <slot 29> : 1 - 28: cast
  |  <slot 30> : CAST(29: subtract AS DECIMAL128(16,2))
  |  <slot 31> : 27: cast * 30: cast
  |  
  0:HdfsScanNode
     TABLE: lineitem
     NON-PARTITION PREDICATES: 11: l_shipdate <= '1998-12-01'
     MIN/MAX PREDICATES: 11: l_shipdate <= '1998-12-01'
     partitions=1/1
     cardinality=600037902
     avgRowSize=70.0
[end]

