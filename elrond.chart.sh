# Elrond real-time node performance and health monitoring
# powered by DisruptiveDigital 2020

# shellcheck shell=bash
# no need for shebang - this file is loaded from charts.d.plugin

# if this chart is called elrond.chart.sh, then all functions and global variables
# must start with elrond_

# update_every is a special variable - it holds the number of seconds
# between the calls of the _update() function
elrond_update_every=10

# the priority is used to sort the charts on the dashboard
# 1 = the first chart
elrond_priority=1

# to enable this chart, you have to set this to 12345
# (just a demonstration for something that needs to be checked)
elrond_magic_number=12345

# global variables to store our collected data
# remember: they need to start with the module name elrond_
elrond_current_round=
elrond_synced_round=
elrond_node_type=
elrond_peer_type=
elrond_shard_id=
elrond_app_version=
elrond_epoch_number=
elrond_connected_peers=
elrond_connected_validators=
elrond_connected_nodes=
elrond_bls=
elrond_tempRating=
elrond_count_consensus=
elrond_count_consensus_accepted_blocks=
elrond_count_leader=
elrond_count_accepted_blocks=

elrond_get() {

  elrond_current_round="$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_current_round )"
  elrond_synced_round="$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_synchronized_round )"
  elrond_node_type="$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_node_type )"
  elrond_peer_type="$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_peer_type )"
  elrond_shard_id="$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_shard_id | head -c2 )"
  elrond_app_version="$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_app_version | head -c10 )"
  elrond_epoch_number="$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_epoch_number )"
  elrond_connected_peers="$( curl -sSL http://localhost:8080/node/status | jq .data.metrics.erd_num_connected_peers )"
  elrond_connected_validators="$( curl -sSL http://localhost:8080/node/heartbeatstatus | jq '.' | grep peerType | grep -c -v observer )"
  elrond_connected_nodes="$( curl -sSL http://localhost:8080/node/status | jq .data.metrics.erd_connected_nodes )"
  elrond_bls="$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_public_key_block_sign )"
  elrond_tempRating="$( curl -sSL https://api.elrond.com/validator/statistics | jq '.data.statistics."'$elrond_bls'".tempRating' | head -c5 )"
  elrond_count_consensus="$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_count_consensus )"
  elrond_count_consensus_accepted_blocks="$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_count_consensus_accepted_blocks )"
  elrond_count_leader="$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_count_leader )"
  elrond_count_accepted_blocks="$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_count_accepted_blocks )"

  # this should return:
  #  - 0 to send the data to netdata
  #  - 1 to report a failure to collect the data
  return 0
}

# _check is called once, to find out if this chart should be enabled or not
elrond_check() {
  # this should return:
  #  - 0 to enable the chart
  #  - 1 to disable the chart

  # check something
  [ "${elrond_magic_number}" != "12345" ] && error "manual configuration required: you have to set elrond_magic_number=$elrond_magic_number in example.conf to start example chart." && return 1

  # check that we can collect data
  elrond_get || return 1

  return 0
}

# _create is called once, to create the charts
elrond_create() {
  # create the chart

  elrond_get || return 1

  cat << EOF
CHART elrond.sync '' "$elrond_node_type/$elrond_peer_type E:$elrond_epoch_number S:$elrond_shard_id P/V/N:$elrond_connected_peers/$elrond_connected_validators/$elrond_connected_nodes R:$elrond_tempRating V:$elrond_app_version" "Round" consensus-round round line $((elrond_priority)) $elrond_update_every
DIMENSION current 'Current' absolute 1 1
DIMENSION synced 'Synced' absolute 1 1
CHART elrond.validatorblocks '' "Validator blocks signed/accepted" "Blocks" validator-blocks blocks line $((elrond_priority + 1)) $elrond_update_every
DIMENSION signedblocks 'Signed' absolute 1 1
DIMENSION signedaccepted 'Accepted' absolute 1 1
CHART elrond.leaderblocks '' "Leader blocks proposed/accepted" "Blocks" leader-blocks blocks line $((elrond_priority + 2)) $elrond_update_every
DIMENSION leaderproposed 'Proposed' absolute 1 1
DIMENSION leaderaccepted 'Accepted' absolute 1 1
CHART elrond.rating '' "Current rating" "Rating" current-rating rating line $((elrond_priority + 3)) $elrond_update_every
DIMENSION rating 'Rating' absolute 1 1
CHART elrond.epoch '' "Current epch" "Epoch" current-epoch epoch line $((elrond_priority + 4)) $elrond_update_every
DIMENSION epoch 'Epoch' absolute 1 1
CHART elrond.connected_pvn '' "Connected peers/validators/nodes" "Peers/Validators/Nodes" peers-validators-nodes pvn line $((elrond_priority + 5)) $elrond_update_every
DIMENSION peers 'Peers' absolute 1 1
DIMENSION validators 'Validators' absolute 1 1
DIMENSION nodes 'Nodes' absolute 1 1
EOF

  return 0
}

# _update is called continuously, to collect the values
elrond_update() {
  # the first argument to this function is the microseconds since last update
  # pass this parameter to the BEGIN statement (see bellow).

  elrond_get || return 1

  # write the result of the work.
  cat << VALUESEOF
BEGIN elrond.sync $1
SET current = $elrond_current_round
SET synced = $elrond_synced_round
END
BEGIN elrond.validatorblocks $1
SET signedblocks = $elrond_count_consensus
SET signedaccepted = $elrond_count_consensus_accepted_blocks
END
BEGIN elrond.leaderblocks $1
SET leaderproposed = $elrond_count_leader
SET leaderaccepted = $elrond_count_accepted_blocks
END
BEGIN elrond.rating $1
SET rating = $elrond_tempRating
END
BEGIN elrond.epoch $1
SET epoch = $elrond_epoch_number
END
BEGIN elrond.connected_pvn $1
SET peers = $elrond_connected_peers
SET validators = $elrond_connected_validators
SET nodes = $elrond_connected_nodes
END
VALUESEOF

  return 0
}
