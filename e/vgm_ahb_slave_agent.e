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


unit slave_agent {
  const id : agent_id;
  const mode : agent_mode_e;

  smap : slave_smap is instance;
    keep smap.agent_id == id;

  monitor : monitor is instance;
    keep monitor.agent_id == id;
    keep monitor.smap == smap;

  when ACTIVE {
    driver : slave_sequence_driver is instance;
      keep driver.agent_id == id;

    bfm : slave_bfm is instance;
      keep bfm.agent_id == id;
      keep bfm.smap == smap;
      keep bfm.driver == driver;
      keep bfm.monitor == monitor;
  };
};
'>


Reset handling
<'
extend slave_agent {
  event unqualified_clock is @smap.HCLK$;
  event reset_start is fall(smap.HRESETn$) @sim;
  event reset_end is rise(smap.HRESETn$) @unqualified_clock;

  on reset_start {
    rerun();
  };

  rerun() is also {
    monitor.rerun();
  };

  when ACTIVE {
    rerun() is also {
      bfm.rerun();
      driver.rerun();
    };
  };
};
'>
