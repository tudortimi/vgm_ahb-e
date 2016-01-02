// Copyright 2016 Tudor Timisescu (verificationgentleman.com)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


<'
package vgm_ahb;


unit slave_bfm {
  agent_id : agent_id;
  smap : slave_smap;

  event clock is true(smap.HRESETn$ == 1) @smap.HCLK$;


  run() is also {
    reset();
  };

  // TODO should use rerun
  reset() is {
    message(NONE, "Resetting");
    smap.HREADY$ = 1;
    smap.HRESP$ = OKAY;
  };
};
'>


<'
extend slave_bfm {
  driver : slave_sequence_driver;
  monitor : monitor;

  on clock {
    emit driver.clock;
  };

  execute_items() @clock is {
    while TRUE {
      sync @monitor.transfer_started;
      smap.HREADY$ = 0;
      driver.bfm_transfer = monitor.transfer;

      var seq_item : transfer = driver.get_next_item();
      // TODO Is there a nice way to pass this from the sequence?
      seq_item.direction = driver.bfm_transfer.direction;
      drive(seq_item);
      emit driver.item_done;
    };
  };

  run() is also {
    start execute_items();
  };

  drive(seq_item : transfer) @clock is {
    message(MEDIUM, "Driving a transfer");
    message(HIGH, "") { print seq_item };
    wait [seq_item.delay];
    smap.HREADY$ = 1;
    smap.HRESP$ = OKAY;
    if seq_item.direction == READ {
      smap.HRDATA$ = seq_item.data;
    };
    wait cycle;
    if seq_item.direction == WRITE {
      seq_item.data = smap.HWDATA$;
    };
  };
};
'>
